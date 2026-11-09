import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/edit_record_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

class FakeCreateRequest extends Fake implements CreateThoughtRecordRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('sends the evidence written with a thought', (tester) async {
    when(() => service.createThoughtRecord(any()))
        .thenAnswer((_) async => ThoughtRecord()..id = 1);

    await tester.pumpWidget(wrap(EditRecordPage(service: service)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'the last train was cancelled',
    );
    await tester.tap(find.text('Add a thought'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'What went through your mind'),
      'I will not get home before midnight',
    );
    await tester.enterText(
      find.byKey(const Key('thoughtEvidence-0')),
      'the replacement bus takes two hours',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => service.createThoughtRecord(captureAny()),
    ).captured.single as CreateThoughtRecordRequest;

    expect(captured.thoughts.single.body, 'I will not get home before midnight');
    expect(
      captured.thoughts.single.evidence,
      'the replacement bus takes two hours',
    );
  });
}
