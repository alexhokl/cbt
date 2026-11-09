import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'challenge_page_test.dart'
    show FakeChallengeRequest, MockRecordService, wrap;

ThoughtRecord buildDetail({
  bool isFactual = false,
  List<CognitiveBias> biases = const <CognitiveBias>[],
}) {
  return ThoughtRecord()
    ..id = 3
    ..event = 'the last train was cancelled'
    ..createdAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 25))
    ..updatedAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 25))
    ..thoughts.add(
      NegativeThought()
        ..id = 7
        ..body = 'I will not get home before midnight'
        ..isFactual = isFactual
        ..biases.addAll(biases),
    );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeChallengeRequest());
  });

  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
  });

  testWidgets('shows nothing against a thought that has not been judged',
      (tester) async {
    when(() => service.getThoughtRecord(3))
        .thenAnswer((_) async => buildDetail());

    await tester.pumpWidget(
      wrap(RecordDetailPage(recordId: 3, service: service)),
    );
    await tester.pumpAndSettle();

    // Carrying no biases is the state every thought starts in, so a freshly
    // written thought must not read as though it had been judged accurate.
    expect(find.text('accurate'), findsNothing);
    expect(find.byType(Chip), findsNothing);
    expect(find.textContaining('Still believe'), findsNothing);
  });

  testWidgets('shows the evidence and how much a thought is still believed',
      (tester) async {
    final record = buildDetail()
      ..evidenceForAlternative = 'the timetable lists a signal fault'
      ..thoughts.first.beliefAfter = 40;
    when(() => service.getThoughtRecord(3)).thenAnswer((_) async => record);

    await tester.pumpWidget(
      wrap(RecordDetailPage(recordId: 3, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Evidence for it'), findsOneWidget);
    expect(find.text('the timetable lists a signal fault'), findsOneWidget);
    expect(find.text('Still believe 40%'), findsOneWidget);
  });

  testWidgets('marks a thought that was judged accurate', (tester) async {
    when(() => service.getThoughtRecord(3))
        .thenAnswer((_) async => buildDetail(isFactual: true));

    await tester.pumpWidget(
      wrap(RecordDetailPage(recordId: 3, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('accurate'), findsOneWidget);
  });

  testWidgets('shows the biases instead when the thought was distorted',
      (tester) async {
    when(() => service.getThoughtRecord(3)).thenAnswer(
      (_) async => buildDetail(
        biases: [
          CognitiveBias()
            ..id = 2
            ..name = 'mind-reading'
            ..isBuiltin = true,
        ],
      ),
    );

    await tester.pumpWidget(
      wrap(RecordDetailPage(recordId: 3, service: service)),
    );
    await tester.pumpAndSettle();

    expect(find.text('mind-reading'), findsOneWidget);
    expect(find.text('accurate'), findsNothing);
  });

  testWidgets('shows the evidence for a thought', (tester) async {
    final record = buildDetail()
      ..thoughts.first.evidence = 'two of the last five trains ran late';
    when(() => service.getThoughtRecord(3)).thenAnswer((_) async => record);

    await tester.pumpWidget(
      wrap(RecordDetailPage(recordId: 3, service: service)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Evidence: two of the last five trains ran late'),
      findsOneWidget,
    );
  });

  testWidgets('adds evidence to a thought after it was written',
      (tester) async {
    when(() => service.getThoughtRecord(3))
        .thenAnswer((_) async => buildDetail());
    when(() => service.setThoughtEvidence(7, any())).thenAnswer(
      (invocation) async => buildDetail()
        ..thoughts.first.evidence =
            invocation.positionalArguments[1] as String,
    );

    await tester.pumpWidget(
      wrap(RecordDetailPage(recordId: 3, service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('I will not get home before midnight'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('thoughtEvidence')),
      'the replacement bus takes two hours',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(
      () => service.setThoughtEvidence(7, 'the replacement bus takes two hours'),
    ).called(1);
    expect(
      find.text('Evidence: the replacement bus takes two hours'),
      findsOneWidget,
    );
    // Adding evidence is not working the record through.
    verifyNever(() => service.challengeThoughtRecord(any()));
  });
}
