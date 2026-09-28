import 'package:cbt/proto/record.pb.dart';
import 'package:cbt/services/record_service.dart';
import 'package:cbt/widgets/record_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'challenge_page_test.dart' show MockRecordService, wrap;

ThoughtRecord buildRecord({
  int id = 1,
  String event = 'an event',
  bool challenged = false,
}) {
  final record = ThoughtRecord()
    ..id = id
    ..event = event
    ..createdAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 25));
  if (challenged) {
    record.challengedAt = Timestamp.fromDateTime(DateTime.utc(2026, 9, 26));
  }
  return record;
}

void main() {
  late MockRecordService service;

  setUp(() {
    service = MockRecordService();
    when(() => service.listMapsOfWorry(search: any(named: 'search')))
        .thenAnswer((_) async => <MapOfWorry>[]);
  });

  testWidgets('opens on the queue of records still to work through',
      (tester) async {
    when(() => service.listThoughtRecords(
          challenged: any(named: 'challenged'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => [buildRecord(event: 'still to do')]);

    await tester.pumpWidget(wrap(RecordList(service: service)));
    await tester.pumpAndSettle();

    // The unchallenged queue is the reason the list is tabbed at all, so it is
    // what the app opens on.
    verify(() => service.listThoughtRecords(challenged: false, search: ''))
        .called(1);
    expect(find.text('still to do'), findsOneWidget);
  });

  testWidgets('offers the challenge action only on unchallenged records',
      (tester) async {
    when(() => service.listThoughtRecords(
          challenged: any(named: 'challenged'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => [
          buildRecord(id: 1, event: 'still to do'),
          buildRecord(id: 2, event: 'already done', challenged: true),
        ]);

    await tester.pumpWidget(wrap(RecordList(service: service)));
    await tester.pumpAndSettle();

    // Working through a record is one tap from the listing rather than buried
    // in the detail page, because that is the daily task.
    expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
  });

  testWidgets('says so explicitly when there is nothing waiting',
      (tester) async {
    when(() => service.listThoughtRecords(
          challenged: any(named: 'challenged'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => <ThoughtRecord>[]);

    await tester.pumpWidget(wrap(RecordList(service: service)));
    await tester.pumpAndSettle();

    // A silent empty list is indistinguishable from a broken connection.
    expect(find.textContaining('Nothing waiting'), findsOneWidget);
  });

  testWidgets('offers a retry when the server cannot be reached',
      (tester) async {
    when(() => service.listThoughtRecords(
          challenged: any(named: 'challenged'),
          search: any(named: 'search'),
        )).thenThrow(RecordException('connection refused'));

    await tester.pumpWidget(wrap(RecordList(service: service)));
    await tester.pumpAndSettle();

    expect(find.text('connection refused'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('switches to maps of worry', (tester) async {
    when(() => service.listThoughtRecords(
          challenged: any(named: 'challenged'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => <ThoughtRecord>[]);
    when(() => service.listMapsOfWorry(search: any(named: 'search')))
        .thenAnswer((_) async => [
              MapOfWorry()
                ..id = 1
                ..event = 'a mapped event'
                ..createdAt =
                    Timestamp.fromDateTime(DateTime.utc(2026, 9, 25)),
            ]);

    await tester.pumpWidget(wrap(RecordList(service: service)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maps of worry'));
    await tester.pumpAndSettle();

    expect(find.text('a mapped event'), findsOneWidget);
  });

  group('strongestFeeling', () {
    test('prefers a rated feeling over an unrated one', () {
      // A rating is a judgement the user made; an absent one is not a zero.
      final result = strongestFeeling([
        Feeling()..name = 'flat',
        Feeling()
          ..name = 'anxious'
          ..intensityBefore = 10,
      ]);

      expect(result, startsWith('anxious'));
    });

    test('counts the feelings it could not show', () {
      final result = strongestFeeling([
        Feeling()
          ..name = 'restless'
          ..intensityBefore = 85,
        Feeling()
          ..name = 'tired'
          ..intensityBefore = 40,
      ]);

      expect(result, 'restless 85% +1');
    });

    test('returns nothing when there are no feelings', () {
      expect(strongestFeeling(<Feeling>[]), isNull);
    });
  });

  group('formatEventDate', () {
    test('marks the fallback to when the record was written', () {
      // A record typed days later would otherwise look like it happened that
      // day, which would quietly corrupt any pattern the user spots.
      final rendered = formatEventDate(null, DateTime.utc(2026, 9, 27));

      expect(rendered, startsWith('~'));
    });

    test('uses the event time when the user gave one', () {
      final rendered = formatEventDate(
        DateTime.utc(2026, 9, 25, 12),
        DateTime.utc(2026, 9, 27),
      );

      expect(rendered, isNot(startsWith('~')));
    });
  });
}
