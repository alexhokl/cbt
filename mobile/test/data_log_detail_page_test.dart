import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/data_log_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

class FakeRateBeliefsRequest extends Fake implements RateBeliefsRequest {}

class FakeDataLogEvidenceInput extends Fake implements DataLogEvidenceInput {}

PositiveDataLog buildLog() {
  return PositiveDataLog()
    ..id = 4
    ..belief = 'I am always late'
    ..alternativeBelief = 'I am on time for most things'
    ..ratings.add(
      BeliefRating()
        ..id = 1
        ..ratedAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 25, 12))
        ..beliefPercent = 70
        ..alternativePercent = 30,
    )
    ..ratings.add(
      BeliefRating()
        ..id = 2
        ..ratedAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 27, 12))
        ..alternativePercent = 45,
    )
    ..evidence.add(
      DataLogEvidence()
        ..id = 7
        ..body = 'arrived early for the dentist'
        ..createdAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 26, 12)),
    );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRateBeliefsRequest());
    registerFallbackValue(FakeDataLogEvidenceInput());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
    when(
      () => service.getPositiveDataLog(4),
    ).thenAnswer((_) async => buildLog());
  });

  testWidgets('shows every rating and the evidence', (tester) async {
    await tester.pumpWidget(
      wrap(DataLogDetailPage(logId: 4, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('I am always late'), findsOneWidget);
    expect(find.text('I am on time for most things'), findsOneWidget);
    expect(find.textContaining('Belief 70% · alternative 30%'), findsOneWidget);
    expect(
      find.textContaining('Belief Not rated · alternative 45%'),
      findsOneWidget,
    );
    expect(find.text('arrived early for the dentist'), findsOneWidget);
  });

  testWidgets('adds a rating without one for the untouched belief', (
    tester,
  ) async {
    when(() => service.rateBeliefs(any())).thenAnswer((_) async => buildLog());

    await tester.pumpWidget(
      wrap(DataLogDetailPage(logId: 4, service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rate again'));
    await tester.pumpAndSettle();

    // Saving with neither slider moved would record nothing.
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Move at least one slider'), findsOneWidget);
    verifyNever(() => service.rateBeliefs(any()));

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('rerateAlternative')),
        matching: find.byType(Slider),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => service.rateBeliefs(captureAny())).captured.single
            as RateBeliefsRequest;
    expect(captured.logId, 4);
    expect(captured.hasBeliefPercent(), isFalse);
    expect(captured.alternativePercent, 50);
  });

  testWidgets('adds a row of evidence', (tester) async {
    when(
      () => service.addDataLogEvidence(any(), any()),
    ).thenAnswer((_) async => buildLog());

    await tester.pumpWidget(
      wrap(DataLogDetailPage(logId: 4, service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add evidence'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('newEvidence')),
      'caught the first train on Monday',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => service.addDataLogEvidence(4, captureAny()),
            ).captured.single
            as DataLogEvidenceInput;
    expect(captured.body, 'caught the first train on Monday');
    expect(captured.hasNotedAt(), isFalse);
  });
}
