import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/edit_experiment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

class FakeCreateExperimentRequest extends Fake
    implements CreateBehaviouralExperimentRequest {}

class FakeUpdateExperimentRequest extends Fake
    implements UpdateBehaviouralExperimentRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateExperimentRequest());
    registerFallbackValue(FakeUpdateExperimentRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('refuses to save without a plan', (tester) async {
    await tester.pumpWidget(wrap(EditExperimentPage(service: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('what you are going to try'), findsOneWidget);
    verifyNever(() => service.createBehaviouralExperiment(any()));
  });

  testWidgets('asks only for the first sitting when creating', (tester) async {
    await tester.pumpWidget(wrap(EditExperimentPage(service: service)));
    await tester.pumpAndSettle();

    // What actually happened is written up once the experiment has been
    // carried out, on its own page.
    expect(find.byKey(const Key('plan')), findsOneWidget);
    expect(find.byKey(const Key('prediction')), findsOneWidget);
    expect(find.byKey(const Key('outcome')), findsNothing);
    expect(find.text('Feelings you predict'), findsOneWidget);
  });

  testWidgets('sends the plan and the prediction', (tester) async {
    when(
      () => service.createBehaviouralExperiment(any()),
    ).thenAnswer((_) async => BehaviouralExperiment()..id = 2);

    await tester.pumpWidget(wrap(EditExperimentPage(service: service)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('plan')),
      'ask a question at the end of the team meeting',
    );
    await tester.enterText(
      find.byKey(const Key('prediction')),
      'someone will think it is obvious',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(
              () => service.createBehaviouralExperiment(captureAny()),
            ).captured.single
            as CreateBehaviouralExperimentRequest;
    expect(captured.plan, 'ask a question at the end of the team meeting');
    expect(captured.prediction, 'someone will think it is obvious');
  });

  testWidgets('shows every column when editing', (tester) async {
    final experiment = BehaviouralExperiment()
      ..id = 2
      ..plan = 'take the earlier train'
      ..outcome = 'the train was quiet';

    await tester.pumpWidget(
      wrap(EditExperimentPage(experiment: experiment, service: service)),
    );
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextField, 'take the earlier train'),
      findsOneWidget,
    );
    // The text fields are scrollables of their own, so the list is named.
    await tester.scrollUntilVisible(
      find.byKey(const Key('buildOn')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.widgetWithText(TextField, 'the train was quiet'),
      findsOneWidget,
    );
  });
}
