import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/edit_record_page.dart';
import 'package:cbt/widgets/feeling_suggestions.dart';
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
    when(
      () => service.createThoughtRecord(any()),
    ).thenAnswer((_) async => ThoughtRecord()..id = 1);

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

    final captured =
        verify(() => service.createThoughtRecord(captureAny())).captured.single
            as CreateThoughtRecordRequest;

    expect(
      captured.thoughts.single.body,
      'I will not get home before midnight',
    );
    expect(
      captured.thoughts.single.evidence,
      'the replacement bus takes two hours',
    );
  });
  testWidgets('records only the name of a suggested feeling', (tester) async {
    when(
      () => service.createThoughtRecord(any()),
    ).thenAnswer((_) async => ThoughtRecord()..id = 1);

    await tester.pumpWidget(wrap(EditRecordPage(service: service)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'the meeting was moved to Friday',
    );
    await tester.tap(find.text('Add a feeling'));
    await tester.pumpAndSettle();

    final feelingField = find.widgetWithText(TextField, 'Feeling');
    await tester.tap(feelingField);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'happy: peaceful, satisfied, and comfortable with your '
        'current state',
      ),
      findsOneWidget,
    );

    await tester.enterText(feelingField, 'wor');
    await tester.pumpAndSettle();
    expect(find.text('content'), findsNothing);
    await tester.tap(find.text('worried'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => service.createThoughtRecord(captureAny())).captured.single
            as CreateThoughtRecordRequest;

    expect(captured.feelings.single.name, 'worried');
  });

  testWidgets('records a feeling name that is not suggested', (tester) async {
    when(
      () => service.createThoughtRecord(any()),
    ).thenAnswer((_) async => ThoughtRecord()..id = 1);

    await tester.pumpWidget(wrap(EditRecordPage(service: service)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'the meeting was moved to Friday',
    );
    await tester.tap(find.text('Add a feeling'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Feeling'),
      'puzzled',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final captured =
        verify(() => service.createThoughtRecord(captureAny())).captured.single
            as CreateThoughtRecordRequest;

    expect(captured.feelings.single.name, 'puzzled');
  });

  test('feeling suggestions are unique names, without the categories', () {
    final names = feelingSuggestions.map((s) => s.name).toList();

    expect(names, hasLength(24));
    expect(names.toSet(), hasLength(names.length));
    for (final name in names) {
      expect(name, name.trim().toLowerCase());
    }
    for (final category in ['happy', 'angry', 'anxious', 'depressed']) {
      expect(names, isNot(contains(category)));
    }
  });

  test('matching puts names starting with the text first', () {
    expect(matchFeelingSuggestions('').length, feelingSuggestions.length);
    expect(matchFeelingSuggestions(' Ten').map((s) => s.name), [
      'tense',
      'content',
    ]);
  });
}
