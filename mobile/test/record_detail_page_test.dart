import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/widgets/record_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

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
}
