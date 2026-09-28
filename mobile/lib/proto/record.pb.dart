// This is a generated file - do not edit.
//
// Generated from proto/record.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// CognitiveBias is a named thinking error. The nine biases catalogued in the
/// source material are seeded per user and marked builtin; builtins cannot be
/// renamed or deleted.
class CognitiveBias extends $pb.GeneratedMessage {
  factory CognitiveBias({
    $core.int? id,
    $core.String? name,
    $core.bool? isBuiltin,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (isBuiltin != null) result.isBuiltin = isBuiltin;
    return result;
  }

  CognitiveBias._();

  factory CognitiveBias.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CognitiveBias.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CognitiveBias',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOB(3, _omitFieldNames ? '' : 'isBuiltin')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CognitiveBias clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CognitiveBias copyWith(void Function(CognitiveBias) updates) =>
      super.copyWith((message) => updates(message as CognitiveBias))
          as CognitiveBias;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CognitiveBias create() => CognitiveBias._();
  @$core.override
  CognitiveBias createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CognitiveBias getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CognitiveBias>(create);
  static CognitiveBias? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isBuiltin => $_getBF(2);
  @$pb.TagNumber(3)
  set isBuiltin($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsBuiltin() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsBuiltin() => $_clearField(3);
}

/// NegativeThought is a single negative automatic thought recorded against a
/// thought record.
class NegativeThought extends $pb.GeneratedMessage {
  factory NegativeThought({
    $core.int? id,
    $core.String? body,
    $core.bool? isHot,
    $core.Iterable<CognitiveBias>? biases,
    $core.int? parentId,
    $core.bool? isFactual,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (body != null) result.body = body;
    if (isHot != null) result.isHot = isHot;
    if (biases != null) result.biases.addAll(biases);
    if (parentId != null) result.parentId = parentId;
    if (isFactual != null) result.isFactual = isFactual;
    return result;
  }

  NegativeThought._();

  factory NegativeThought.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NegativeThought.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NegativeThought',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOB(3, _omitFieldNames ? '' : 'isHot')
    ..pPM<CognitiveBias>(4, _omitFieldNames ? '' : 'biases',
        subBuilder: CognitiveBias.create)
    ..aI(5, _omitFieldNames ? '' : 'parentId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(6, _omitFieldNames ? '' : 'isFactual')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NegativeThought clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NegativeThought copyWith(void Function(NegativeThought) updates) =>
      super.copyWith((message) => updates(message as NegativeThought))
          as NegativeThought;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NegativeThought create() => NegativeThought._();
  @$core.override
  NegativeThought createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NegativeThought getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NegativeThought>(create);
  static NegativeThought? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  /// is_hot marks the strongest thought of the record, the one worth
  /// challenging first. At most one thought per record carries it.
  @$pb.TagNumber(3)
  $core.bool get isHot => $_getBF(2);
  @$pb.TagNumber(3)
  set isHot($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsHot() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsHot() => $_clearField(3);

  /// biases are the thinking errors identified in this thought. The bias
  /// belongs to the thought rather than the record because each thought carries
  /// its own distortion.
  @$pb.TagNumber(4)
  $pb.PbList<CognitiveBias> get biases => $_getList(3);

  /// parent_id links this thought to the thought whose meaning it is, forming
  /// the chain produced by the downward arrow technique. No RPC populates it
  /// yet; the field is reserved so the chain can be recorded later.
  @$pb.TagNumber(5)
  $core.int get parentId => $_getIZ(4);
  @$pb.TagNumber(5)
  set parentId($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasParentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearParentId() => $_clearField(5);

  /// is_factual records that the thought was examined and judged an accurate
  /// reading of the situation rather than a distorted one. It cannot be
  /// inferred from carrying no biases, because that is the state every thought
  /// starts in. A thought that is factual never carries a bias.
  @$pb.TagNumber(6)
  $core.bool get isFactual => $_getBF(5);
  @$pb.TagNumber(6)
  set isFactual($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsFactual() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsFactual() => $_clearField(6);
}

/// Feeling is a single emotion rated on a 0-100 scale.
class Feeling extends $pb.GeneratedMessage {
  factory Feeling({
    $core.int? id,
    $core.String? name,
    $core.int? intensityBefore,
    $core.int? intensityAfter,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (intensityBefore != null) result.intensityBefore = intensityBefore;
    if (intensityAfter != null) result.intensityAfter = intensityAfter;
    return result;
  }

  Feeling._();

  factory Feeling.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Feeling.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Feeling',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'intensityBefore')
    ..aI(4, _omitFieldNames ? '' : 'intensityAfter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Feeling clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Feeling copyWith(void Function(Feeling) updates) =>
      super.copyWith((message) => updates(message as Feeling)) as Feeling;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Feeling create() => Feeling._();
  @$core.override
  Feeling createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Feeling getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Feeling>(create);
  static Feeling? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// intensity_before is the rating given when the feeling was recorded.
  @$pb.TagNumber(3)
  $core.int get intensityBefore => $_getIZ(2);
  @$pb.TagNumber(3)
  set intensityBefore($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIntensityBefore() => $_has(2);
  @$pb.TagNumber(3)
  void clearIntensityBefore() => $_clearField(3);

  /// intensity_after is the re-rating given during the challenge. It is only
  /// ever set on feelings belonging to a thought record.
  @$pb.TagNumber(4)
  $core.int get intensityAfter => $_getIZ(3);
  @$pb.TagNumber(4)
  set intensityAfter($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIntensityAfter() => $_has(3);
  @$pb.TagNumber(4)
  void clearIntensityAfter() => $_clearField(4);
}

/// ThoughtRecord is the six column thought record: event, negative thought(s),
/// negative feeling(s), cognitive bias, "is there any other way I can look at
/// this?", and "how do I feel now?".
class ThoughtRecord extends $pb.GeneratedMessage {
  factory ThoughtRecord({
    $core.int? id,
    $core.String? event,
    $2.Timestamp? occurredAt,
    $core.String? alternativeView,
    $core.String? feelingsNow,
    $2.Timestamp? challengedAt,
    $core.Iterable<NegativeThought>? thoughts,
    $core.Iterable<Feeling>? feelings,
    $2.Timestamp? createdAt,
    $2.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (event != null) result.event = event;
    if (occurredAt != null) result.occurredAt = occurredAt;
    if (alternativeView != null) result.alternativeView = alternativeView;
    if (feelingsNow != null) result.feelingsNow = feelingsNow;
    if (challengedAt != null) result.challengedAt = challengedAt;
    if (thoughts != null) result.thoughts.addAll(thoughts);
    if (feelings != null) result.feelings.addAll(feelings);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  ThoughtRecord._();

  factory ThoughtRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ThoughtRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ThoughtRecord',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'event')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $2.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'alternativeView')
    ..aOS(5, _omitFieldNames ? '' : 'feelingsNow')
    ..aOM<$2.Timestamp>(6, _omitFieldNames ? '' : 'challengedAt',
        subBuilder: $2.Timestamp.create)
    ..pPM<NegativeThought>(7, _omitFieldNames ? '' : 'thoughts',
        subBuilder: NegativeThought.create)
    ..pPM<Feeling>(8, _omitFieldNames ? '' : 'feelings',
        subBuilder: Feeling.create)
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThoughtRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThoughtRecord copyWith(void Function(ThoughtRecord) updates) =>
      super.copyWith((message) => updates(message as ThoughtRecord))
          as ThoughtRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThoughtRecord create() => ThoughtRecord._();
  @$core.override
  ThoughtRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ThoughtRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ThoughtRecord>(create);
  static ThoughtRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get event => $_getSZ(1);
  @$pb.TagNumber(2)
  set event($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);

  /// occurred_at is when the event happened, which is frequently not when the
  /// record was typed. It is absent when the user did not say.
  @$pb.TagNumber(3)
  $2.Timestamp get occurredAt => $_getN(2);
  @$pb.TagNumber(3)
  set occurredAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOccurredAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearOccurredAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureOccurredAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get alternativeView => $_getSZ(3);
  @$pb.TagNumber(4)
  set alternativeView($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlternativeView() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlternativeView() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get feelingsNow => $_getSZ(4);
  @$pb.TagNumber(5)
  set feelingsNow($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeelingsNow() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeelingsNow() => $_clearField(5);

  /// challenged_at is set once the second sitting has happened, and absent
  /// while the record is still in the work queue.
  @$pb.TagNumber(6)
  $2.Timestamp get challengedAt => $_getN(5);
  @$pb.TagNumber(6)
  set challengedAt($2.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasChallengedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearChallengedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.Timestamp ensureChallengedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<NegativeThought> get thoughts => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<Feeling> get feelings => $_getList(7);

  @$pb.TagNumber(9)
  $2.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($2.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureCreatedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $2.Timestamp get updatedAt => $_getN(9);
  @$pb.TagNumber(10)
  set updatedAt($2.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasUpdatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearUpdatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureUpdatedAt() => $_ensure(9);
}

/// MapOfWorry traces a single event through to the behaviour it produced.
class MapOfWorry extends $pb.GeneratedMessage {
  factory MapOfWorry({
    $core.int? id,
    $core.String? event,
    $2.Timestamp? occurredAt,
    $core.String? thoughts,
    $core.String? whatTheseThoughtsMean,
    $core.String? physicalSensations,
    $core.String? resultantBehaviour,
    $core.int? derivedFromId,
    $core.Iterable<Feeling>? feelings,
    $2.Timestamp? createdAt,
    $2.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (event != null) result.event = event;
    if (occurredAt != null) result.occurredAt = occurredAt;
    if (thoughts != null) result.thoughts = thoughts;
    if (whatTheseThoughtsMean != null)
      result.whatTheseThoughtsMean = whatTheseThoughtsMean;
    if (physicalSensations != null)
      result.physicalSensations = physicalSensations;
    if (resultantBehaviour != null)
      result.resultantBehaviour = resultantBehaviour;
    if (derivedFromId != null) result.derivedFromId = derivedFromId;
    if (feelings != null) result.feelings.addAll(feelings);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  MapOfWorry._();

  factory MapOfWorry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MapOfWorry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MapOfWorry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'event')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $2.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'thoughts')
    ..aOS(5, _omitFieldNames ? '' : 'whatTheseThoughtsMean')
    ..aOS(6, _omitFieldNames ? '' : 'physicalSensations')
    ..aOS(7, _omitFieldNames ? '' : 'resultantBehaviour')
    ..aI(8, _omitFieldNames ? '' : 'derivedFromId',
        fieldType: $pb.PbFieldType.OU3)
    ..pPM<Feeling>(9, _omitFieldNames ? '' : 'feelings',
        subBuilder: Feeling.create)
    ..aOM<$2.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MapOfWorry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MapOfWorry copyWith(void Function(MapOfWorry) updates) =>
      super.copyWith((message) => updates(message as MapOfWorry)) as MapOfWorry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MapOfWorry create() => MapOfWorry._();
  @$core.override
  MapOfWorry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MapOfWorry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MapOfWorry>(create);
  static MapOfWorry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get event => $_getSZ(1);
  @$pb.TagNumber(2)
  set event($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get occurredAt => $_getN(2);
  @$pb.TagNumber(3)
  set occurredAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOccurredAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearOccurredAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureOccurredAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get thoughts => $_getSZ(3);
  @$pb.TagNumber(4)
  set thoughts($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasThoughts() => $_has(3);
  @$pb.TagNumber(4)
  void clearThoughts() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get whatTheseThoughtsMean => $_getSZ(4);
  @$pb.TagNumber(5)
  set whatTheseThoughtsMean($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWhatTheseThoughtsMean() => $_has(4);
  @$pb.TagNumber(5)
  void clearWhatTheseThoughtsMean() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get physicalSensations => $_getSZ(5);
  @$pb.TagNumber(6)
  set physicalSensations($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPhysicalSensations() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhysicalSensations() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get resultantBehaviour => $_getSZ(6);
  @$pb.TagNumber(7)
  set resultantBehaviour($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResultantBehaviour() => $_has(6);
  @$pb.TagNumber(7)
  void clearResultantBehaviour() => $_clearField(7);

  /// derived_from_id points at the map this one reworks. The contrast between
  /// the two is the therapeutic payload, so they are read side by side.
  @$pb.TagNumber(8)
  $core.int get derivedFromId => $_getIZ(7);
  @$pb.TagNumber(8)
  set derivedFromId($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDerivedFromId() => $_has(7);
  @$pb.TagNumber(8)
  void clearDerivedFromId() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<Feeling> get feelings => $_getList(8);

  @$pb.TagNumber(10)
  $2.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($2.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $2.Timestamp ensureCreatedAt() => $_ensure(9);

  @$pb.TagNumber(11)
  $2.Timestamp get updatedAt => $_getN(10);
  @$pb.TagNumber(11)
  set updatedAt($2.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $2.Timestamp ensureUpdatedAt() => $_ensure(10);
}

/// FeelingInput is a feeling as supplied by the client: a name and an optional
/// 0-100 rating.
class FeelingInput extends $pb.GeneratedMessage {
  factory FeelingInput({
    $core.String? name,
    $core.int? intensity,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (intensity != null) result.intensity = intensity;
    return result;
  }

  FeelingInput._();

  factory FeelingInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeelingInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeelingInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aI(2, _omitFieldNames ? '' : 'intensity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeelingInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeelingInput copyWith(void Function(FeelingInput) updates) =>
      super.copyWith((message) => updates(message as FeelingInput))
          as FeelingInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeelingInput create() => FeelingInput._();
  @$core.override
  FeelingInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeelingInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FeelingInput>(create);
  static FeelingInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get intensity => $_getIZ(1);
  @$pb.TagNumber(2)
  set intensity($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIntensity() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntensity() => $_clearField(2);
}

/// ThoughtInput is a negative automatic thought as supplied by the client.
class ThoughtInput extends $pb.GeneratedMessage {
  factory ThoughtInput({
    $core.String? body,
    $core.bool? isHot,
    $core.Iterable<$core.String>? biases,
  }) {
    final result = create();
    if (body != null) result.body = body;
    if (isHot != null) result.isHot = isHot;
    if (biases != null) result.biases.addAll(biases);
    return result;
  }

  ThoughtInput._();

  factory ThoughtInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ThoughtInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ThoughtInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'body')
    ..aOB(2, _omitFieldNames ? '' : 'isHot')
    ..pPS(3, _omitFieldNames ? '' : 'biases')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThoughtInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThoughtInput copyWith(void Function(ThoughtInput) updates) =>
      super.copyWith((message) => updates(message as ThoughtInput))
          as ThoughtInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThoughtInput create() => ThoughtInput._();
  @$core.override
  ThoughtInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ThoughtInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ThoughtInput>(create);
  static ThoughtInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get body => $_getSZ(0);
  @$pb.TagNumber(1)
  set body($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBody() => $_has(0);
  @$pb.TagNumber(1)
  void clearBody() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isHot => $_getBF(1);
  @$pb.TagNumber(2)
  set isHot($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsHot() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsHot() => $_clearField(2);

  /// biases must already exist. A bias is a vocabulary term rather than a free
  /// tag, so an unrecognised name is reported as a typo rather than coined.
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get biases => $_getList(2);
}

class ListThoughtRecordsRequest extends $pb.GeneratedMessage {
  factory ListThoughtRecordsRequest({
    $core.bool? challenged,
    $2.Timestamp? since,
    $core.String? search,
  }) {
    final result = create();
    if (challenged != null) result.challenged = challenged;
    if (since != null) result.since = since;
    if (search != null) result.search = search;
    return result;
  }

  ListThoughtRecordsRequest._();

  factory ListThoughtRecordsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListThoughtRecordsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListThoughtRecordsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'challenged')
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'since',
        subBuilder: $2.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'search')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListThoughtRecordsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListThoughtRecordsRequest copyWith(
          void Function(ListThoughtRecordsRequest) updates) =>
      super.copyWith((message) => updates(message as ListThoughtRecordsRequest))
          as ListThoughtRecordsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListThoughtRecordsRequest create() => ListThoughtRecordsRequest._();
  @$core.override
  ListThoughtRecordsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListThoughtRecordsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListThoughtRecordsRequest>(create);
  static ListThoughtRecordsRequest? _defaultInstance;

  /// challenged filters by whether the record has been challenged. Absent
  /// returns both; false is the day's work queue.
  @$pb.TagNumber(1)
  $core.bool get challenged => $_getBF(0);
  @$pb.TagNumber(1)
  set challenged($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChallenged() => $_has(0);
  @$pb.TagNumber(1)
  void clearChallenged() => $_clearField(1);

  /// since restricts the listing to records whose event occurred on or after
  /// this instant.
  @$pb.TagNumber(2)
  $2.Timestamp get since => $_getN(1);
  @$pb.TagNumber(2)
  set since($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSince() => $_has(1);
  @$pb.TagNumber(2)
  void clearSince() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureSince() => $_ensure(1);

  /// search matches the event, the alternative view and the thought bodies.
  @$pb.TagNumber(3)
  $core.String get search => $_getSZ(2);
  @$pb.TagNumber(3)
  set search($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSearch() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearch() => $_clearField(3);
}

class ListThoughtRecordsResponse extends $pb.GeneratedMessage {
  factory ListThoughtRecordsResponse({
    $core.Iterable<ThoughtRecord>? records,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    return result;
  }

  ListThoughtRecordsResponse._();

  factory ListThoughtRecordsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListThoughtRecordsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListThoughtRecordsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..pPM<ThoughtRecord>(1, _omitFieldNames ? '' : 'records',
        subBuilder: ThoughtRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListThoughtRecordsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListThoughtRecordsResponse copyWith(
          void Function(ListThoughtRecordsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListThoughtRecordsResponse))
          as ListThoughtRecordsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListThoughtRecordsResponse create() => ListThoughtRecordsResponse._();
  @$core.override
  ListThoughtRecordsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListThoughtRecordsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListThoughtRecordsResponse>(create);
  static ListThoughtRecordsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ThoughtRecord> get records => $_getList(0);
}

class CreateThoughtRecordRequest extends $pb.GeneratedMessage {
  factory CreateThoughtRecordRequest({
    $core.String? event,
    $2.Timestamp? occurredAt,
    $core.String? alternativeView,
    $core.String? feelingsNow,
    $core.Iterable<ThoughtInput>? thoughts,
    $core.Iterable<FeelingInput>? feelings,
  }) {
    final result = create();
    if (event != null) result.event = event;
    if (occurredAt != null) result.occurredAt = occurredAt;
    if (alternativeView != null) result.alternativeView = alternativeView;
    if (feelingsNow != null) result.feelingsNow = feelingsNow;
    if (thoughts != null) result.thoughts.addAll(thoughts);
    if (feelings != null) result.feelings.addAll(feelings);
    return result;
  }

  CreateThoughtRecordRequest._();

  factory CreateThoughtRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateThoughtRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateThoughtRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'event')
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $2.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'alternativeView')
    ..aOS(4, _omitFieldNames ? '' : 'feelingsNow')
    ..pPM<ThoughtInput>(5, _omitFieldNames ? '' : 'thoughts',
        subBuilder: ThoughtInput.create)
    ..pPM<FeelingInput>(6, _omitFieldNames ? '' : 'feelings',
        subBuilder: FeelingInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateThoughtRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateThoughtRecordRequest copyWith(
          void Function(CreateThoughtRecordRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateThoughtRecordRequest))
          as CreateThoughtRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateThoughtRecordRequest create() => CreateThoughtRecordRequest._();
  @$core.override
  CreateThoughtRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateThoughtRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateThoughtRecordRequest>(create);
  static CreateThoughtRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get event => $_getSZ(0);
  @$pb.TagNumber(1)
  set event($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.Timestamp get occurredAt => $_getN(1);
  @$pb.TagNumber(2)
  set occurredAt($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOccurredAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearOccurredAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureOccurredAt() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get alternativeView => $_getSZ(2);
  @$pb.TagNumber(3)
  set alternativeView($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAlternativeView() => $_has(2);
  @$pb.TagNumber(3)
  void clearAlternativeView() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get feelingsNow => $_getSZ(3);
  @$pb.TagNumber(4)
  set feelingsNow($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeelingsNow() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeelingsNow() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<ThoughtInput> get thoughts => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<FeelingInput> get feelings => $_getList(5);
}

class GetThoughtRecordRequest extends $pb.GeneratedMessage {
  factory GetThoughtRecordRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetThoughtRecordRequest._();

  factory GetThoughtRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetThoughtRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetThoughtRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetThoughtRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetThoughtRecordRequest copyWith(
          void Function(GetThoughtRecordRequest) updates) =>
      super.copyWith((message) => updates(message as GetThoughtRecordRequest))
          as GetThoughtRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetThoughtRecordRequest create() => GetThoughtRecordRequest._();
  @$core.override
  GetThoughtRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetThoughtRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetThoughtRecordRequest>(create);
  static GetThoughtRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class UpdateThoughtRecordRequest extends $pb.GeneratedMessage {
  factory UpdateThoughtRecordRequest({
    $core.int? id,
    $core.String? event,
    $2.Timestamp? occurredAt,
    $core.bool? clearOccurredAt_4,
    $core.String? alternativeView,
    $core.String? feelingsNow,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (event != null) result.event = event;
    if (occurredAt != null) result.occurredAt = occurredAt;
    if (clearOccurredAt_4 != null) result.clearOccurredAt_4 = clearOccurredAt_4;
    if (alternativeView != null) result.alternativeView = alternativeView;
    if (feelingsNow != null) result.feelingsNow = feelingsNow;
    return result;
  }

  UpdateThoughtRecordRequest._();

  factory UpdateThoughtRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateThoughtRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateThoughtRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'event')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $2.Timestamp.create)
    ..aOB(4, _omitFieldNames ? '' : 'clearOccurredAt')
    ..aOS(5, _omitFieldNames ? '' : 'alternativeView')
    ..aOS(6, _omitFieldNames ? '' : 'feelingsNow')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateThoughtRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateThoughtRecordRequest copyWith(
          void Function(UpdateThoughtRecordRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdateThoughtRecordRequest))
          as UpdateThoughtRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateThoughtRecordRequest create() => UpdateThoughtRecordRequest._();
  @$core.override
  UpdateThoughtRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateThoughtRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateThoughtRecordRequest>(create);
  static UpdateThoughtRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Unset fields keep their current value, which is what allows a record to be
  /// completed one column at a time.
  @$pb.TagNumber(2)
  $core.String get event => $_getSZ(1);
  @$pb.TagNumber(2)
  set event($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get occurredAt => $_getN(2);
  @$pb.TagNumber(3)
  set occurredAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOccurredAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearOccurredAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureOccurredAt() => $_ensure(2);

  /// clear_occurred_at distinguishes "leave the event time alone" from "forget
  /// when it happened", which an absent occurred_at alone cannot express.
  @$pb.TagNumber(4)
  $core.bool get clearOccurredAt_4 => $_getBF(3);
  @$pb.TagNumber(4)
  set clearOccurredAt_4($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClearOccurredAt_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearClearOccurredAt_4() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get alternativeView => $_getSZ(4);
  @$pb.TagNumber(5)
  set alternativeView($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAlternativeView() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlternativeView() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get feelingsNow => $_getSZ(5);
  @$pb.TagNumber(6)
  set feelingsNow($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFeelingsNow() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeelingsNow() => $_clearField(6);
}

/// ThoughtJudgement is the outcome of examining one thought during the
/// challenge: which distortions it carries, or that it carries none because the
/// thought was an accurate reading of the situation.
class ThoughtJudgement extends $pb.GeneratedMessage {
  factory ThoughtJudgement({
    $core.int? thoughtId,
    BiasNames? biases,
    $core.bool? isFactual,
  }) {
    final result = create();
    if (thoughtId != null) result.thoughtId = thoughtId;
    if (biases != null) result.biases = biases;
    if (isFactual != null) result.isFactual = isFactual;
    return result;
  }

  ThoughtJudgement._();

  factory ThoughtJudgement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ThoughtJudgement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ThoughtJudgement',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'thoughtId', fieldType: $pb.PbFieldType.OU3)
    ..aOM<BiasNames>(2, _omitFieldNames ? '' : 'biases',
        subBuilder: BiasNames.create)
    ..aOB(3, _omitFieldNames ? '' : 'isFactual')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThoughtJudgement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ThoughtJudgement copyWith(void Function(ThoughtJudgement) updates) =>
      super.copyWith((message) => updates(message as ThoughtJudgement))
          as ThoughtJudgement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ThoughtJudgement create() => ThoughtJudgement._();
  @$core.override
  ThoughtJudgement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ThoughtJudgement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ThoughtJudgement>(create);
  static ThoughtJudgement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get thoughtId => $_getIZ(0);
  @$pb.TagNumber(1)
  set thoughtId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasThoughtId() => $_has(0);
  @$pb.TagNumber(1)
  void clearThoughtId() => $_clearField(1);

  /// biases replaces whatever the thought carried, so re-running a challenge
  /// with a corrected list leaves the corrected list. Leaving it unset keeps
  /// the existing biases, so a judgement can record only that a thought is
  /// factual; setting it to an empty list detaches them all.
  @$pb.TagNumber(2)
  BiasNames get biases => $_getN(1);
  @$pb.TagNumber(2)
  set biases(BiasNames value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBiases() => $_has(1);
  @$pb.TagNumber(2)
  void clearBiases() => $_clearField(2);
  @$pb.TagNumber(2)
  BiasNames ensureBiases() => $_ensure(1);

  /// is_factual records that the thought was judged an accurate reading.
  /// Marking a thought factual while it still carries a bias is rejected.
  @$pb.TagNumber(3)
  $core.bool get isFactual => $_getBF(2);
  @$pb.TagNumber(3)
  set isFactual($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsFactual() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsFactual() => $_clearField(3);
}

/// FeelingRerating is the post-challenge rating of one feeling.
class FeelingRerating extends $pb.GeneratedMessage {
  factory FeelingRerating({
    $core.int? feelingId,
    $core.int? intensityAfter,
  }) {
    final result = create();
    if (feelingId != null) result.feelingId = feelingId;
    if (intensityAfter != null) result.intensityAfter = intensityAfter;
    return result;
  }

  FeelingRerating._();

  factory FeelingRerating.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeelingRerating.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeelingRerating',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'feelingId', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'intensityAfter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeelingRerating clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeelingRerating copyWith(void Function(FeelingRerating) updates) =>
      super.copyWith((message) => updates(message as FeelingRerating))
          as FeelingRerating;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeelingRerating create() => FeelingRerating._();
  @$core.override
  FeelingRerating createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeelingRerating getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FeelingRerating>(create);
  static FeelingRerating? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get feelingId => $_getIZ(0);
  @$pb.TagNumber(1)
  set feelingId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFeelingId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeelingId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get intensityAfter => $_getIZ(1);
  @$pb.TagNumber(2)
  set intensityAfter($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIntensityAfter() => $_has(1);
  @$pb.TagNumber(2)
  void clearIntensityAfter() => $_clearField(2);
}

class ChallengeThoughtRecordRequest extends $pb.GeneratedMessage {
  factory ChallengeThoughtRecordRequest({
    $core.int? id,
    $core.String? alternativeView,
    $core.String? feelingsNow,
    $core.Iterable<FeelingRerating>? feelingReratings,
    $core.Iterable<ThoughtJudgement>? thoughts,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (alternativeView != null) result.alternativeView = alternativeView;
    if (feelingsNow != null) result.feelingsNow = feelingsNow;
    if (feelingReratings != null)
      result.feelingReratings.addAll(feelingReratings);
    if (thoughts != null) result.thoughts.addAll(thoughts);
    return result;
  }

  ChallengeThoughtRecordRequest._();

  factory ChallengeThoughtRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChallengeThoughtRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChallengeThoughtRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'alternativeView')
    ..aOS(3, _omitFieldNames ? '' : 'feelingsNow')
    ..pPM<FeelingRerating>(4, _omitFieldNames ? '' : 'feelingReratings',
        subBuilder: FeelingRerating.create)
    ..pPM<ThoughtJudgement>(5, _omitFieldNames ? '' : 'thoughts',
        subBuilder: ThoughtJudgement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChallengeThoughtRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChallengeThoughtRecordRequest copyWith(
          void Function(ChallengeThoughtRecordRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ChallengeThoughtRecordRequest))
          as ChallengeThoughtRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChallengeThoughtRecordRequest create() =>
      ChallengeThoughtRecordRequest._();
  @$core.override
  ChallengeThoughtRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChallengeThoughtRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChallengeThoughtRecordRequest>(create);
  static ChallengeThoughtRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get alternativeView => $_getSZ(1);
  @$pb.TagNumber(2)
  set alternativeView($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlternativeView() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlternativeView() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get feelingsNow => $_getSZ(2);
  @$pb.TagNumber(3)
  set feelingsNow($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeelingsNow() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeelingsNow() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<FeelingRerating> get feelingReratings => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<ThoughtJudgement> get thoughts => $_getList(4);
}

class DeleteThoughtRecordRequest extends $pb.GeneratedMessage {
  factory DeleteThoughtRecordRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteThoughtRecordRequest._();

  factory DeleteThoughtRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteThoughtRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteThoughtRecordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteThoughtRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteThoughtRecordRequest copyWith(
          void Function(DeleteThoughtRecordRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteThoughtRecordRequest))
          as DeleteThoughtRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteThoughtRecordRequest create() => DeleteThoughtRecordRequest._();
  @$core.override
  DeleteThoughtRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteThoughtRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteThoughtRecordRequest>(create);
  static DeleteThoughtRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class AddThoughtRequest extends $pb.GeneratedMessage {
  factory AddThoughtRequest({
    $core.int? recordId,
    ThoughtInput? thought,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (thought != null) result.thought = thought;
    return result;
  }

  AddThoughtRequest._();

  factory AddThoughtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddThoughtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddThoughtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'recordId', fieldType: $pb.PbFieldType.OU3)
    ..aOM<ThoughtInput>(2, _omitFieldNames ? '' : 'thought',
        subBuilder: ThoughtInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddThoughtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddThoughtRequest copyWith(void Function(AddThoughtRequest) updates) =>
      super.copyWith((message) => updates(message as AddThoughtRequest))
          as AddThoughtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddThoughtRequest create() => AddThoughtRequest._();
  @$core.override
  AddThoughtRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddThoughtRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddThoughtRequest>(create);
  static AddThoughtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get recordId => $_getIZ(0);
  @$pb.TagNumber(1)
  set recordId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  ThoughtInput get thought => $_getN(1);
  @$pb.TagNumber(2)
  set thought(ThoughtInput value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasThought() => $_has(1);
  @$pb.TagNumber(2)
  void clearThought() => $_clearField(2);
  @$pb.TagNumber(2)
  ThoughtInput ensureThought() => $_ensure(1);
}

class UpdateThoughtRequest extends $pb.GeneratedMessage {
  factory UpdateThoughtRequest({
    $core.int? id,
    $core.String? body,
    BiasNames? biases,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (body != null) result.body = body;
    if (biases != null) result.biases = biases;
    return result;
  }

  UpdateThoughtRequest._();

  factory UpdateThoughtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateThoughtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateThoughtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOM<BiasNames>(3, _omitFieldNames ? '' : 'biases',
        subBuilder: BiasNames.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateThoughtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateThoughtRequest copyWith(void Function(UpdateThoughtRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateThoughtRequest))
          as UpdateThoughtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateThoughtRequest create() => UpdateThoughtRequest._();
  @$core.override
  UpdateThoughtRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateThoughtRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateThoughtRequest>(create);
  static UpdateThoughtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  /// biases replaces the biases on the thought when set. Leaving it unset keeps
  /// the existing biases, so the wording can be corrected without redoing the
  /// bias work; setting it to an empty list detaches them all.
  @$pb.TagNumber(3)
  BiasNames get biases => $_getN(2);
  @$pb.TagNumber(3)
  set biases(BiasNames value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBiases() => $_has(2);
  @$pb.TagNumber(3)
  void clearBiases() => $_clearField(3);
  @$pb.TagNumber(3)
  BiasNames ensureBiases() => $_ensure(2);
}

/// BiasNames wraps a repeated field so that "not given" can be told apart from
/// "given as empty". proto3 cannot mark a repeated field optional.
class BiasNames extends $pb.GeneratedMessage {
  factory BiasNames({
    $core.Iterable<$core.String>? names,
  }) {
    final result = create();
    if (names != null) result.names.addAll(names);
    return result;
  }

  BiasNames._();

  factory BiasNames.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BiasNames.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BiasNames',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'names')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BiasNames clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BiasNames copyWith(void Function(BiasNames) updates) =>
      super.copyWith((message) => updates(message as BiasNames)) as BiasNames;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BiasNames create() => BiasNames._();
  @$core.override
  BiasNames createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BiasNames getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BiasNames>(create);
  static BiasNames? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get names => $_getList(0);
}

class SetHotThoughtRequest extends $pb.GeneratedMessage {
  factory SetHotThoughtRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  SetHotThoughtRequest._();

  factory SetHotThoughtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetHotThoughtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetHotThoughtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetHotThoughtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetHotThoughtRequest copyWith(void Function(SetHotThoughtRequest) updates) =>
      super.copyWith((message) => updates(message as SetHotThoughtRequest))
          as SetHotThoughtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetHotThoughtRequest create() => SetHotThoughtRequest._();
  @$core.override
  SetHotThoughtRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetHotThoughtRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetHotThoughtRequest>(create);
  static SetHotThoughtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SetThoughtFactualRequest extends $pb.GeneratedMessage {
  factory SetThoughtFactualRequest({
    $core.int? id,
    $core.bool? factual,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (factual != null) result.factual = factual;
    return result;
  }

  SetThoughtFactualRequest._();

  factory SetThoughtFactualRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetThoughtFactualRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetThoughtFactualRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOB(2, _omitFieldNames ? '' : 'factual')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetThoughtFactualRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetThoughtFactualRequest copyWith(
          void Function(SetThoughtFactualRequest) updates) =>
      super.copyWith((message) => updates(message as SetThoughtFactualRequest))
          as SetThoughtFactualRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetThoughtFactualRequest create() => SetThoughtFactualRequest._();
  @$core.override
  SetThoughtFactualRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetThoughtFactualRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetThoughtFactualRequest>(create);
  static SetThoughtFactualRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get factual => $_getBF(1);
  @$pb.TagNumber(2)
  set factual($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFactual() => $_has(1);
  @$pb.TagNumber(2)
  void clearFactual() => $_clearField(2);
}

class DeleteThoughtRequest extends $pb.GeneratedMessage {
  factory DeleteThoughtRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteThoughtRequest._();

  factory DeleteThoughtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteThoughtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteThoughtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteThoughtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteThoughtRequest copyWith(void Function(DeleteThoughtRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteThoughtRequest))
          as DeleteThoughtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteThoughtRequest create() => DeleteThoughtRequest._();
  @$core.override
  DeleteThoughtRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteThoughtRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteThoughtRequest>(create);
  static DeleteThoughtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class AddFeelingRequest extends $pb.GeneratedMessage {
  factory AddFeelingRequest({
    $core.int? recordId,
    FeelingInput? feeling,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (feeling != null) result.feeling = feeling;
    return result;
  }

  AddFeelingRequest._();

  factory AddFeelingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddFeelingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddFeelingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'recordId', fieldType: $pb.PbFieldType.OU3)
    ..aOM<FeelingInput>(2, _omitFieldNames ? '' : 'feeling',
        subBuilder: FeelingInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddFeelingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddFeelingRequest copyWith(void Function(AddFeelingRequest) updates) =>
      super.copyWith((message) => updates(message as AddFeelingRequest))
          as AddFeelingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddFeelingRequest create() => AddFeelingRequest._();
  @$core.override
  AddFeelingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddFeelingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddFeelingRequest>(create);
  static AddFeelingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get recordId => $_getIZ(0);
  @$pb.TagNumber(1)
  set recordId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  FeelingInput get feeling => $_getN(1);
  @$pb.TagNumber(2)
  set feeling(FeelingInput value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeling() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeling() => $_clearField(2);
  @$pb.TagNumber(2)
  FeelingInput ensureFeeling() => $_ensure(1);
}

class AddMapFeelingRequest extends $pb.GeneratedMessage {
  factory AddMapFeelingRequest({
    $core.int? mapId,
    FeelingInput? feeling,
  }) {
    final result = create();
    if (mapId != null) result.mapId = mapId;
    if (feeling != null) result.feeling = feeling;
    return result;
  }

  AddMapFeelingRequest._();

  factory AddMapFeelingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMapFeelingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMapFeelingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'mapId', fieldType: $pb.PbFieldType.OU3)
    ..aOM<FeelingInput>(2, _omitFieldNames ? '' : 'feeling',
        subBuilder: FeelingInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMapFeelingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMapFeelingRequest copyWith(void Function(AddMapFeelingRequest) updates) =>
      super.copyWith((message) => updates(message as AddMapFeelingRequest))
          as AddMapFeelingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMapFeelingRequest create() => AddMapFeelingRequest._();
  @$core.override
  AddMapFeelingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMapFeelingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMapFeelingRequest>(create);
  static AddMapFeelingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get mapId => $_getIZ(0);
  @$pb.TagNumber(1)
  set mapId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMapId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMapId() => $_clearField(1);

  @$pb.TagNumber(2)
  FeelingInput get feeling => $_getN(1);
  @$pb.TagNumber(2)
  set feeling(FeelingInput value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeling() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeling() => $_clearField(2);
  @$pb.TagNumber(2)
  FeelingInput ensureFeeling() => $_ensure(1);
}

class DeleteFeelingRequest extends $pb.GeneratedMessage {
  factory DeleteFeelingRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteFeelingRequest._();

  factory DeleteFeelingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFeelingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFeelingRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFeelingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFeelingRequest copyWith(void Function(DeleteFeelingRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteFeelingRequest))
          as DeleteFeelingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFeelingRequest create() => DeleteFeelingRequest._();
  @$core.override
  DeleteFeelingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFeelingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFeelingRequest>(create);
  static DeleteFeelingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ListMapsOfWorryRequest extends $pb.GeneratedMessage {
  factory ListMapsOfWorryRequest({
    $2.Timestamp? since,
    $core.String? search,
  }) {
    final result = create();
    if (since != null) result.since = since;
    if (search != null) result.search = search;
    return result;
  }

  ListMapsOfWorryRequest._();

  factory ListMapsOfWorryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMapsOfWorryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMapsOfWorryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOM<$2.Timestamp>(1, _omitFieldNames ? '' : 'since',
        subBuilder: $2.Timestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'search')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMapsOfWorryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMapsOfWorryRequest copyWith(
          void Function(ListMapsOfWorryRequest) updates) =>
      super.copyWith((message) => updates(message as ListMapsOfWorryRequest))
          as ListMapsOfWorryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMapsOfWorryRequest create() => ListMapsOfWorryRequest._();
  @$core.override
  ListMapsOfWorryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMapsOfWorryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMapsOfWorryRequest>(create);
  static ListMapsOfWorryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Timestamp get since => $_getN(0);
  @$pb.TagNumber(1)
  set since($2.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSince() => $_has(0);
  @$pb.TagNumber(1)
  void clearSince() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Timestamp ensureSince() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get search => $_getSZ(1);
  @$pb.TagNumber(2)
  set search($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSearch() => $_has(1);
  @$pb.TagNumber(2)
  void clearSearch() => $_clearField(2);
}

class ListMapsOfWorryResponse extends $pb.GeneratedMessage {
  factory ListMapsOfWorryResponse({
    $core.Iterable<MapOfWorry>? maps,
  }) {
    final result = create();
    if (maps != null) result.maps.addAll(maps);
    return result;
  }

  ListMapsOfWorryResponse._();

  factory ListMapsOfWorryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMapsOfWorryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMapsOfWorryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..pPM<MapOfWorry>(1, _omitFieldNames ? '' : 'maps',
        subBuilder: MapOfWorry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMapsOfWorryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMapsOfWorryResponse copyWith(
          void Function(ListMapsOfWorryResponse) updates) =>
      super.copyWith((message) => updates(message as ListMapsOfWorryResponse))
          as ListMapsOfWorryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMapsOfWorryResponse create() => ListMapsOfWorryResponse._();
  @$core.override
  ListMapsOfWorryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMapsOfWorryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMapsOfWorryResponse>(create);
  static ListMapsOfWorryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MapOfWorry> get maps => $_getList(0);
}

class CreateMapOfWorryRequest extends $pb.GeneratedMessage {
  factory CreateMapOfWorryRequest({
    $core.String? event,
    $2.Timestamp? occurredAt,
    $core.String? thoughts,
    $core.String? whatTheseThoughtsMean,
    $core.String? physicalSensations,
    $core.String? resultantBehaviour,
    $core.int? derivedFromId,
    $core.Iterable<FeelingInput>? feelings,
  }) {
    final result = create();
    if (event != null) result.event = event;
    if (occurredAt != null) result.occurredAt = occurredAt;
    if (thoughts != null) result.thoughts = thoughts;
    if (whatTheseThoughtsMean != null)
      result.whatTheseThoughtsMean = whatTheseThoughtsMean;
    if (physicalSensations != null)
      result.physicalSensations = physicalSensations;
    if (resultantBehaviour != null)
      result.resultantBehaviour = resultantBehaviour;
    if (derivedFromId != null) result.derivedFromId = derivedFromId;
    if (feelings != null) result.feelings.addAll(feelings);
    return result;
  }

  CreateMapOfWorryRequest._();

  factory CreateMapOfWorryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateMapOfWorryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateMapOfWorryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'event')
    ..aOM<$2.Timestamp>(2, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $2.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'thoughts')
    ..aOS(4, _omitFieldNames ? '' : 'whatTheseThoughtsMean')
    ..aOS(5, _omitFieldNames ? '' : 'physicalSensations')
    ..aOS(6, _omitFieldNames ? '' : 'resultantBehaviour')
    ..aI(7, _omitFieldNames ? '' : 'derivedFromId',
        fieldType: $pb.PbFieldType.OU3)
    ..pPM<FeelingInput>(8, _omitFieldNames ? '' : 'feelings',
        subBuilder: FeelingInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMapOfWorryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMapOfWorryRequest copyWith(
          void Function(CreateMapOfWorryRequest) updates) =>
      super.copyWith((message) => updates(message as CreateMapOfWorryRequest))
          as CreateMapOfWorryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMapOfWorryRequest create() => CreateMapOfWorryRequest._();
  @$core.override
  CreateMapOfWorryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateMapOfWorryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMapOfWorryRequest>(create);
  static CreateMapOfWorryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get event => $_getSZ(0);
  @$pb.TagNumber(1)
  set event($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);

  @$pb.TagNumber(2)
  $2.Timestamp get occurredAt => $_getN(1);
  @$pb.TagNumber(2)
  set occurredAt($2.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOccurredAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearOccurredAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.Timestamp ensureOccurredAt() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get thoughts => $_getSZ(2);
  @$pb.TagNumber(3)
  set thoughts($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasThoughts() => $_has(2);
  @$pb.TagNumber(3)
  void clearThoughts() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get whatTheseThoughtsMean => $_getSZ(3);
  @$pb.TagNumber(4)
  set whatTheseThoughtsMean($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWhatTheseThoughtsMean() => $_has(3);
  @$pb.TagNumber(4)
  void clearWhatTheseThoughtsMean() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get physicalSensations => $_getSZ(4);
  @$pb.TagNumber(5)
  set physicalSensations($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPhysicalSensations() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhysicalSensations() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get resultantBehaviour => $_getSZ(5);
  @$pb.TagNumber(6)
  set resultantBehaviour($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasResultantBehaviour() => $_has(5);
  @$pb.TagNumber(6)
  void clearResultantBehaviour() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get derivedFromId => $_getIZ(6);
  @$pb.TagNumber(7)
  set derivedFromId($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDerivedFromId() => $_has(6);
  @$pb.TagNumber(7)
  void clearDerivedFromId() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<FeelingInput> get feelings => $_getList(7);
}

class GetMapOfWorryRequest extends $pb.GeneratedMessage {
  factory GetMapOfWorryRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetMapOfWorryRequest._();

  factory GetMapOfWorryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMapOfWorryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMapOfWorryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMapOfWorryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMapOfWorryRequest copyWith(void Function(GetMapOfWorryRequest) updates) =>
      super.copyWith((message) => updates(message as GetMapOfWorryRequest))
          as GetMapOfWorryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMapOfWorryRequest create() => GetMapOfWorryRequest._();
  @$core.override
  GetMapOfWorryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMapOfWorryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMapOfWorryRequest>(create);
  static GetMapOfWorryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// GetMapOfWorryResponse carries the map together with the maps it should be
/// read against: the one it reworks, and the reworkings of it.
class GetMapOfWorryResponse extends $pb.GeneratedMessage {
  factory GetMapOfWorryResponse({
    MapOfWorry? map,
    MapOfWorry? derivedFrom,
    $core.Iterable<MapOfWorry>? alternatives,
  }) {
    final result = create();
    if (map != null) result.map = map;
    if (derivedFrom != null) result.derivedFrom = derivedFrom;
    if (alternatives != null) result.alternatives.addAll(alternatives);
    return result;
  }

  GetMapOfWorryResponse._();

  factory GetMapOfWorryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMapOfWorryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMapOfWorryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOM<MapOfWorry>(1, _omitFieldNames ? '' : 'map',
        subBuilder: MapOfWorry.create)
    ..aOM<MapOfWorry>(2, _omitFieldNames ? '' : 'derivedFrom',
        subBuilder: MapOfWorry.create)
    ..pPM<MapOfWorry>(3, _omitFieldNames ? '' : 'alternatives',
        subBuilder: MapOfWorry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMapOfWorryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMapOfWorryResponse copyWith(
          void Function(GetMapOfWorryResponse) updates) =>
      super.copyWith((message) => updates(message as GetMapOfWorryResponse))
          as GetMapOfWorryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMapOfWorryResponse create() => GetMapOfWorryResponse._();
  @$core.override
  GetMapOfWorryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMapOfWorryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMapOfWorryResponse>(create);
  static GetMapOfWorryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MapOfWorry get map => $_getN(0);
  @$pb.TagNumber(1)
  set map(MapOfWorry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMap() => $_has(0);
  @$pb.TagNumber(1)
  void clearMap() => $_clearField(1);
  @$pb.TagNumber(1)
  MapOfWorry ensureMap() => $_ensure(0);

  /// derived_from is the map this one reworks, when it is an alternative.
  @$pb.TagNumber(2)
  MapOfWorry get derivedFrom => $_getN(1);
  @$pb.TagNumber(2)
  set derivedFrom(MapOfWorry value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDerivedFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivedFrom() => $_clearField(2);
  @$pb.TagNumber(2)
  MapOfWorry ensureDerivedFrom() => $_ensure(1);

  /// alternatives are the maps derived from this one.
  @$pb.TagNumber(3)
  $pb.PbList<MapOfWorry> get alternatives => $_getList(2);
}

class UpdateMapOfWorryRequest extends $pb.GeneratedMessage {
  factory UpdateMapOfWorryRequest({
    $core.int? id,
    $core.String? event,
    $2.Timestamp? occurredAt,
    $core.bool? clearOccurredAt_4,
    $core.String? thoughts,
    $core.String? whatTheseThoughtsMean,
    $core.String? physicalSensations,
    $core.String? resultantBehaviour,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (event != null) result.event = event;
    if (occurredAt != null) result.occurredAt = occurredAt;
    if (clearOccurredAt_4 != null) result.clearOccurredAt_4 = clearOccurredAt_4;
    if (thoughts != null) result.thoughts = thoughts;
    if (whatTheseThoughtsMean != null)
      result.whatTheseThoughtsMean = whatTheseThoughtsMean;
    if (physicalSensations != null)
      result.physicalSensations = physicalSensations;
    if (resultantBehaviour != null)
      result.resultantBehaviour = resultantBehaviour;
    return result;
  }

  UpdateMapOfWorryRequest._();

  factory UpdateMapOfWorryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateMapOfWorryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateMapOfWorryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'event')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'occurredAt',
        subBuilder: $2.Timestamp.create)
    ..aOB(4, _omitFieldNames ? '' : 'clearOccurredAt')
    ..aOS(5, _omitFieldNames ? '' : 'thoughts')
    ..aOS(6, _omitFieldNames ? '' : 'whatTheseThoughtsMean')
    ..aOS(7, _omitFieldNames ? '' : 'physicalSensations')
    ..aOS(8, _omitFieldNames ? '' : 'resultantBehaviour')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMapOfWorryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMapOfWorryRequest copyWith(
          void Function(UpdateMapOfWorryRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateMapOfWorryRequest))
          as UpdateMapOfWorryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateMapOfWorryRequest create() => UpdateMapOfWorryRequest._();
  @$core.override
  UpdateMapOfWorryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateMapOfWorryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateMapOfWorryRequest>(create);
  static UpdateMapOfWorryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get event => $_getSZ(1);
  @$pb.TagNumber(2)
  set event($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get occurredAt => $_getN(2);
  @$pb.TagNumber(3)
  set occurredAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOccurredAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearOccurredAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureOccurredAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get clearOccurredAt_4 => $_getBF(3);
  @$pb.TagNumber(4)
  set clearOccurredAt_4($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClearOccurredAt_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearClearOccurredAt_4() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get thoughts => $_getSZ(4);
  @$pb.TagNumber(5)
  set thoughts($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThoughts() => $_has(4);
  @$pb.TagNumber(5)
  void clearThoughts() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get whatTheseThoughtsMean => $_getSZ(5);
  @$pb.TagNumber(6)
  set whatTheseThoughtsMean($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWhatTheseThoughtsMean() => $_has(5);
  @$pb.TagNumber(6)
  void clearWhatTheseThoughtsMean() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get physicalSensations => $_getSZ(6);
  @$pb.TagNumber(7)
  set physicalSensations($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPhysicalSensations() => $_has(6);
  @$pb.TagNumber(7)
  void clearPhysicalSensations() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get resultantBehaviour => $_getSZ(7);
  @$pb.TagNumber(8)
  set resultantBehaviour($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasResultantBehaviour() => $_has(7);
  @$pb.TagNumber(8)
  void clearResultantBehaviour() => $_clearField(8);
}

class DeleteMapOfWorryRequest extends $pb.GeneratedMessage {
  factory DeleteMapOfWorryRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteMapOfWorryRequest._();

  factory DeleteMapOfWorryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteMapOfWorryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteMapOfWorryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMapOfWorryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteMapOfWorryRequest copyWith(
          void Function(DeleteMapOfWorryRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteMapOfWorryRequest))
          as DeleteMapOfWorryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteMapOfWorryRequest create() => DeleteMapOfWorryRequest._();
  @$core.override
  DeleteMapOfWorryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteMapOfWorryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteMapOfWorryRequest>(create);
  static DeleteMapOfWorryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ListBiasesRequest extends $pb.GeneratedMessage {
  factory ListBiasesRequest() => create();

  ListBiasesRequest._();

  factory ListBiasesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListBiasesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListBiasesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBiasesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBiasesRequest copyWith(void Function(ListBiasesRequest) updates) =>
      super.copyWith((message) => updates(message as ListBiasesRequest))
          as ListBiasesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBiasesRequest create() => ListBiasesRequest._();
  @$core.override
  ListBiasesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListBiasesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBiasesRequest>(create);
  static ListBiasesRequest? _defaultInstance;
}

class ListBiasesResponse extends $pb.GeneratedMessage {
  factory ListBiasesResponse({
    $core.Iterable<CognitiveBias>? biases,
  }) {
    final result = create();
    if (biases != null) result.biases.addAll(biases);
    return result;
  }

  ListBiasesResponse._();

  factory ListBiasesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListBiasesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListBiasesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..pPM<CognitiveBias>(1, _omitFieldNames ? '' : 'biases',
        subBuilder: CognitiveBias.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBiasesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBiasesResponse copyWith(void Function(ListBiasesResponse) updates) =>
      super.copyWith((message) => updates(message as ListBiasesResponse))
          as ListBiasesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBiasesResponse create() => ListBiasesResponse._();
  @$core.override
  ListBiasesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListBiasesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBiasesResponse>(create);
  static ListBiasesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CognitiveBias> get biases => $_getList(0);
}

class CreateBiasRequest extends $pb.GeneratedMessage {
  factory CreateBiasRequest({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  CreateBiasRequest._();

  factory CreateBiasRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateBiasRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateBiasRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBiasRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBiasRequest copyWith(void Function(CreateBiasRequest) updates) =>
      super.copyWith((message) => updates(message as CreateBiasRequest))
          as CreateBiasRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBiasRequest create() => CreateBiasRequest._();
  @$core.override
  CreateBiasRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateBiasRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBiasRequest>(create);
  static CreateBiasRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class RenameBiasRequest extends $pb.GeneratedMessage {
  factory RenameBiasRequest({
    $core.int? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  RenameBiasRequest._();

  factory RenameBiasRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RenameBiasRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RenameBiasRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameBiasRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RenameBiasRequest copyWith(void Function(RenameBiasRequest) updates) =>
      super.copyWith((message) => updates(message as RenameBiasRequest))
          as RenameBiasRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RenameBiasRequest create() => RenameBiasRequest._();
  @$core.override
  RenameBiasRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RenameBiasRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RenameBiasRequest>(create);
  static RenameBiasRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class DeleteBiasRequest extends $pb.GeneratedMessage {
  factory DeleteBiasRequest({
    $core.int? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteBiasRequest._();

  factory DeleteBiasRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteBiasRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteBiasRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'record'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteBiasRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteBiasRequest copyWith(void Function(DeleteBiasRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteBiasRequest))
          as DeleteBiasRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteBiasRequest create() => DeleteBiasRequest._();
  @$core.override
  DeleteBiasRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteBiasRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteBiasRequest>(create);
  static DeleteBiasRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
