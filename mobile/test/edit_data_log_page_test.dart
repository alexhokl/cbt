import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/edit_data_log_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

class FakeCreateDataLogRequest extends Fake
    implements CreatePositiveDataLogRequest {}

class FakeUpdateDataLogRequest extends Fake
    implements UpdatePositiveDataLogRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateDataLogRequest());
    registerFallbackValue(FakeUpdateDataLogRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('refuses to save without a belief', (tester) async {
    await tester.pumpWidget(wrap(EditDataLogPage(service: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Write down the belief'), findsOneWidget);
    verifyNever(() => service.createPositiveDataLog(any()));
  });

  testWidgets('sends no rating until a slider is moved', (tester) async {
    // The whole form, evidence included, fits without scrolling.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    when(
      () => service.createPositiveDataLog(any()),
    ).thenAnswer((_) async => PositiveDataLog()..id = 4);

    await tester.pumpWidget(wrap(EditDataLogPage(service: service)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('belief')), 'I am always late');
    await tester.enterText(
      find.byKey(const Key('alternativeBelief')),
      'I am on time for most things',
    );
    await tester.tap(find.text('Add evidence'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('evidence-0')),
      'arrived early for the dentist',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => service.createPositiveDataLog(captureAny()),
            ).captured.single
            as CreatePositiveDataLogRequest;
    expect(captured.belief, 'I am always late');
    expect(captured.alternativeBelief, 'I am on time for most things');
    expect(captured.hasBeliefPercent(), isFalse);
    expect(captured.hasAlternativePercent(), isFalse);
    expect(captured.evidence.single.body, 'arrived early for the dentist');
  });

  testWidgets('sends a rating once its slider is moved', (tester) async {
    when(
      () => service.createPositiveDataLog(any()),
    ).thenAnswer((_) async => PositiveDataLog()..id = 4);

    await tester.pumpWidget(wrap(EditDataLogPage(service: service)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('belief')), 'I am always late');
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('believeBelief')),
        matching: find.byType(Slider),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => service.createPositiveDataLog(captureAny()),
            ).captured.single
            as CreatePositiveDataLogRequest;
    // Tapping the centre of the slider sets it to the middle of the range.
    expect(captured.beliefPercent, 50);
    expect(captured.hasAlternativePercent(), isFalse);
  });

  testWidgets('rewords only, when editing', (tester) async {
    when(
      () => service.updatePositiveDataLog(any()),
    ).thenAnswer((_) async => PositiveDataLog()..id = 4);

    final log = PositiveDataLog()
      ..id = 4
      ..belief = 'I am always late'
      ..alternativeBelief = 'I am sometimes late';

    await tester.pumpWidget(wrap(EditDataLogPage(log: log, service: service)));
    await tester.pumpAndSettle();

    // Ratings and evidence are added from the detail page, so the earlier
    // ones are never rewritten here.
    expect(find.byType(Slider), findsNothing);
    expect(find.text('Add evidence'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('alternativeBelief')),
      'I am on time for most things',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => service.updatePositiveDataLog(captureAny()),
            ).captured.single
            as UpdatePositiveDataLogRequest;
    expect(captured.id, 4);
    expect(captured.alternativeBelief, 'I am on time for most things');
  });
}
