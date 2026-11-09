import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/complete_experiment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

class FakeCompleteExperimentRequest extends Fake
    implements CompleteBehaviouralExperimentRequest {}

BehaviouralExperiment buildExperiment() {
  return BehaviouralExperiment()
    ..id = 2
    ..plan = 'ask a question at the end of the team meeting'
    ..prediction = 'someone will think it is obvious'
    ..feelings.add(
      Feeling()
        ..id = 5
        ..name = 'embarrassed'
        ..intensityBefore = 70,
    );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCompleteExperimentRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('shows the plan and the prediction, read only', (tester) async {
    await tester.pumpWidget(
      wrap(
        CompleteExperimentPage(experiment: buildExperiment(), service: service),
      ),
    );
    await tester.pumpAndSettle();

    // What happened is set against what was predicted, so the prediction is
    // shown as it was written and cannot be changed here.
    expect(find.text('someone will think it is obvious'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'someone will think it is obvious'),
      findsNothing,
    );
    expect(find.text('70% → 70%'), findsOneWidget);
  });

  testWidgets('sends the outcome and how each feeling was actually felt', (
    tester,
  ) async {
    when(
      () => service.completeBehaviouralExperiment(any()),
    ).thenAnswer((_) async => buildExperiment());

    await tester.pumpWidget(
      wrap(
        CompleteExperimentPage(experiment: buildExperiment(), service: service),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('outcome')),
      'two people said they had the same question',
    );

    final list = find.byType(Scrollable).first;
    // Tapping the middle of the slider rates the feeling at 50%.
    await tester.scrollUntilVisible(
      find.byKey(const Key('rerate-5')),
      200,
      scrollable: list,
    );
    await tester.tap(find.byKey(const Key('rerate-5')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('learned')),
      200,
      scrollable: list,
    );
    await tester.enterText(
      find.byKey(const Key('learned')),
      'the question was worth asking',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => service.completeBehaviouralExperiment(captureAny()),
            ).captured.single
            as CompleteBehaviouralExperimentRequest;
    expect(captured.id, 2);
    expect(captured.outcome, 'two people said they had the same question');
    expect(captured.learned, 'the question was worth asking');
    expect(captured.feelingReratings, hasLength(1));
    expect(captured.feelingReratings.single.feelingId, 5);
    expect(captured.feelingReratings.single.intensityAfter, 50);
    expect(captured.newFeelings, isEmpty);
  });
}
