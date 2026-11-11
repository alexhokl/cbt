import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/services/record_service.dart';
import 'package:cbt/widgets/formulation_detail_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

void main() {
  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('shows only the columns written', (tester) async {
    when(() => service.getFormulation(2)).thenAnswer(
      (_) async => Formulation()
        ..id = 2
        ..earlyExperiences = 'moved school three times as a child'
        ..beliefs = 'people move on'
        ..behaviours = 'eats at the desk',
    );

    await tester.pumpWidget(
      wrap(FormulationDetailPage(formulationId: 2, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Early life experiences'), findsOneWidget);
    expect(find.text('moved school three times as a child'), findsOneWidget);
    expect(find.text('people move on'), findsOneWidget);
    expect(find.text('Behaviours maintaining the problem'), findsOneWidget);
    expect(find.text('Assumptions'), findsNothing);
    expect(find.text('Rules for living'), findsNothing);
  });

  testWidgets('offers a retry when the server cannot be reached', (
    tester,
  ) async {
    when(
      () => service.getFormulation(2),
    ).thenThrow(RecordException('unavailable'));

    await tester.pumpWidget(
      wrap(FormulationDetailPage(formulationId: 2, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
  });
}
