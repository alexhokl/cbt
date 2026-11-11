import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/edit_formulation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

class FakeCreateFormulationRequest extends Fake
    implements CreateFormulationRequest {}

class FakeUpdateFormulationRequest extends Fake
    implements UpdateFormulationRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateFormulationRequest());
    registerFallbackValue(FakeUpdateFormulationRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('refuses to save an empty formulation', (tester) async {
    await tester.pumpWidget(wrap(EditFormulationPage(service: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('at least one column'), findsOneWidget);
    verifyNever(() => service.createFormulation(any()));
  });

  testWidgets('saves from any single column', (tester) async {
    // All seven fields fit without scrolling.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    when(
      () => service.createFormulation(any()),
    ).thenAnswer((_) async => Formulation()..id = 2);

    await tester.pumpWidget(wrap(EditFormulationPage(service: service)));
    await tester.pumpAndSettle();

    // Working backwards from the behaviours is as valid as starting from the
    // early experiences.
    await tester.enterText(
      find.byKey(const Key('formulation-6')),
      'eats at the desk',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => service.createFormulation(captureAny())).captured.single
            as CreateFormulationRequest;
    expect(captured.behaviours, 'eats at the desk');
    expect(captured.earlyExperiences, isEmpty);
  });

  testWidgets('shows the columns in the order of the exercise', (tester) async {
    await tester.pumpWidget(wrap(EditFormulationPage(service: service)));
    await tester.pumpAndSettle();

    final early = tester.getTopLeft(find.text('Early life experiences')).dy;
    final beliefs = tester.getTopLeft(find.text('Beliefs')).dy;
    final assumptions = tester.getTopLeft(find.text('Assumptions')).dy;
    expect(early, lessThan(beliefs));
    expect(beliefs, lessThan(assumptions));
  });

  testWidgets('edits an existing formulation', (tester) async {
    when(
      () => service.updateFormulation(any()),
    ).thenAnswer((_) async => Formulation()..id = 2);

    final formulation = Formulation()
      ..id = 2
      ..beliefs = 'people move on';

    await tester.pumpWidget(
      wrap(EditFormulationPage(formulation: formulation, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('people move on'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('formulation-2')),
      'if I get attached, it will end',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => service.updateFormulation(captureAny())).captured.single
            as UpdateFormulationRequest;
    expect(captured.id, 2);
    expect(captured.beliefs, 'people move on');
    expect(captured.assumptions, 'if I get attached, it will end');
  });
}
