import 'package:cbt/l10n/app_localizations.dart';
import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/services/record_service.dart';
import 'package:cbt/widgets/challenge_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecordService extends Mock implements RecordService {}

class FakeChallengeRequest extends Fake
    implements ChallengeThoughtRecordRequest {}

/// Wraps a page in the localisations and theme it expects, so a test does not
/// have to build a whole app.
Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

ThoughtRecord buildRecord() {
  return ThoughtRecord()
    ..id = 3
    ..event = 'a meeting was moved without telling me'
    ..thoughts.add(
      NegativeThought()
        ..id = 7
        ..body = 'they do not think my input matters'
        ..isHot = true,
    )
    ..feelings.add(
      Feeling()
        ..id = 4
        ..name = 'anxious'
        ..intensityBefore = 80,
    );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeChallengeRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
    when(() => service.listBiases()).thenAnswer(
      (_) async => [
        CognitiveBias()
          ..id = 1
          ..name = 'catastrophising'
          ..isBuiltin = true,
        CognitiveBias()
          ..id = 2
          ..name = 'mind-reading'
          ..isBuiltin = true,
      ],
    );
  });

  testWidgets('shows the record as written, read only', (tester) async {
    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    // The point of the exercise is to read back what you thought at the time
    // and answer against it, so the event must be shown but not editable here.
    expect(find.text('a meeting was moved without telling me'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'a meeting was moved without telling me'),
      findsNothing,
    );
  });

  testWidgets('offers the bias vocabulary against each thought',
      (tester) async {
    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    // A bias belongs to a thought, not to the record, so the chips sit under
    // the thought they describe.
    expect(find.widgetWithText(FilterChip, 'catastrophising'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'mind-reading'), findsOneWidget);
  });

  testWidgets('sends the alternative view, biases and re-ratings',
      (tester) async {
    when(() => service.challengeThoughtRecord(any()))
        .thenAnswer((_) async => buildRecord());

    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'catastrophising'));
    await tester.pumpAndSettle();

    // The field is below the fold in a lazily built list, so it has to be
    // scrolled into existence before it can be typed into. Finding it by key
    // rather than by position also stops the test depending on layout order.
    await tester.scrollUntilVisible(
      find.byKey(const Key('alternativeView')),
      200,
    );
    await tester.enterText(
      find.byKey(const Key('alternativeView')),
      'the invite may simply have failed to send',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => service.challengeThoughtRecord(captureAny()),
    ).captured.single as ChallengeThoughtRecordRequest;

    expect(captured.id, 3);
    expect(
      captured.alternativeView,
      'the invite may simply have failed to send',
    );
    expect(captured.thoughts.single.thoughtId, 7);
    expect(captured.thoughts.single.biases.names, contains('catastrophising'));
    expect(captured.feelingReratings.single.feelingId, 4);
  });

  testWidgets('starts a re-rating at the original rating', (tester) async {
    when(() => service.challengeThoughtRecord(any()))
        .thenAnswer((_) async => buildRecord());

    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => service.challengeThoughtRecord(captureAny()),
    ).captured.single as ChallengeThoughtRecordRequest;

    // An untouched slider must record "unchanged" rather than silently
    // dropping the feeling to zero, which would read as a resolved record.
    expect(captured.feelingReratings.single.intensityAfter, 80);
  });

  testWidgets('keeps the biases a thought already carried', (tester) async {
    final record = buildRecord()
      ..thoughts.first.biases.add(
        CognitiveBias()
          ..id = 2
          ..name = 'mind-reading'
          ..isBuiltin = true,
      );
    when(() => service.challengeThoughtRecord(any()))
        .thenAnswer((_) async => record);

    await tester.pumpWidget(
      wrap(ChallengePage(record: record, service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => service.challengeThoughtRecord(captureAny()),
    ).captured.single as ChallengeThoughtRecordRequest;

    // Re-running a challenge replaces the bias list, so anything already
    // selected has to be sent back or it would be silently dropped.
    expect(captured.thoughts.single.biases.names, contains('mind-reading'));
  });

  testWidgets('sends an empty bias list when no chip is selected',
      (tester) async {
    when(() => service.challengeThoughtRecord(any()))
        .thenAnswer((_) async => buildRecord());

    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => service.challengeThoughtRecord(captureAny()),
    ).captured.single as ChallengeThoughtRecordRequest;

    // The wrapper must be present but empty. An absent wrapper means "leave
    // the biases alone", which is the opposite instruction, and would make a
    // thought impossible to record as carrying no distortion.
    expect(captured.thoughts.single.hasBiases(), isTrue);
    expect(captured.thoughts.single.biases.names, isEmpty);
  });

  testWidgets('marking a thought accurate clears its biases', (tester) async {
    when(() => service.challengeThoughtRecord(any()))
        .thenAnswer((_) async => buildRecord());

    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'catastrophising'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => service.challengeThoughtRecord(captureAny()),
    ).captured.single as ChallengeThoughtRecordRequest;

    // A thought is never both accurate and distorted. The screen clears the
    // selection rather than letting the server refuse a request it should not
    // have been possible to build.
    expect(captured.thoughts.single.isFactual, isTrue);
    expect(captured.thoughts.single.biases.names, isEmpty);
  });

  testWidgets('disables the bias chips once a thought is accurate',
      (tester) async {
    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'catastrophising'),
    );
    // Disabled rather than hidden, so the reason they cannot be used stays
    // visible next to the switch that caused it.
    expect(chip.onSelected, isNull);
  });

  testWidgets('reports a failure without leaving the page', (tester) async {
    when(() => service.challengeThoughtRecord(any()))
        .thenThrow(RecordException('could not reach the server'));

    await tester.pumpWidget(
      wrap(ChallengePage(record: buildRecord(), service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('could not reach the server'), findsOneWidget);
    expect(find.byType(ChallengePage), findsOneWidget);
  });
}
