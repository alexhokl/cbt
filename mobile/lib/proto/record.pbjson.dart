// This is a generated file - do not edit.
//
// Generated from proto/record.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use cognitiveBiasDescriptor instead')
const CognitiveBias$json = {
  '1': 'CognitiveBias',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'is_builtin', '3': 3, '4': 1, '5': 8, '10': 'isBuiltin'},
  ],
};

/// Descriptor for `CognitiveBias`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cognitiveBiasDescriptor = $convert.base64Decode(
    'Cg1Db2duaXRpdmVCaWFzEg4KAmlkGAEgASgNUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh0KCm'
    'lzX2J1aWx0aW4YAyABKAhSCWlzQnVpbHRpbg==');

@$core.Deprecated('Use negativeThoughtDescriptor instead')
const NegativeThought$json = {
  '1': 'NegativeThought',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {'1': 'is_hot', '3': 3, '4': 1, '5': 8, '10': 'isHot'},
    {
      '1': 'biases',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.record.CognitiveBias',
      '10': 'biases'
    },
    {
      '1': 'parent_id',
      '3': 5,
      '4': 1,
      '5': 13,
      '9': 0,
      '10': 'parentId',
      '17': true
    },
    {'1': 'is_factual', '3': 6, '4': 1, '5': 8, '10': 'isFactual'},
    {
      '1': 'belief_after',
      '3': 7,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'beliefAfter',
      '17': true
    },
    {'1': 'evidence', '3': 8, '4': 1, '5': 9, '10': 'evidence'},
  ],
  '8': [
    {'1': '_parent_id'},
    {'1': '_belief_after'},
  ],
};

/// Descriptor for `NegativeThought`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List negativeThoughtDescriptor = $convert.base64Decode(
    'Cg9OZWdhdGl2ZVRob3VnaHQSDgoCaWQYASABKA1SAmlkEhIKBGJvZHkYAiABKAlSBGJvZHkSFQ'
    'oGaXNfaG90GAMgASgIUgVpc0hvdBItCgZiaWFzZXMYBCADKAsyFS5yZWNvcmQuQ29nbml0aXZl'
    'Qmlhc1IGYmlhc2VzEiAKCXBhcmVudF9pZBgFIAEoDUgAUghwYXJlbnRJZIgBARIdCgppc19mYW'
    'N0dWFsGAYgASgIUglpc0ZhY3R1YWwSJgoMYmVsaWVmX2FmdGVyGAcgASgFSAFSC2JlbGllZkFm'
    'dGVyiAEBEhoKCGV2aWRlbmNlGAggASgJUghldmlkZW5jZUIMCgpfcGFyZW50X2lkQg8KDV9iZW'
    'xpZWZfYWZ0ZXI=');

@$core.Deprecated('Use feelingDescriptor instead')
const Feeling$json = {
  '1': 'Feeling',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'intensity_before',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'intensityBefore',
      '17': true
    },
    {
      '1': 'intensity_after',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'intensityAfter',
      '17': true
    },
  ],
  '8': [
    {'1': '_intensity_before'},
    {'1': '_intensity_after'},
  ],
};

/// Descriptor for `Feeling`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feelingDescriptor = $convert.base64Decode(
    'CgdGZWVsaW5nEg4KAmlkGAEgASgNUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEi4KEGludGVuc2'
    'l0eV9iZWZvcmUYAyABKAVIAFIPaW50ZW5zaXR5QmVmb3JliAEBEiwKD2ludGVuc2l0eV9hZnRl'
    'chgEIAEoBUgBUg5pbnRlbnNpdHlBZnRlcogBAUITChFfaW50ZW5zaXR5X2JlZm9yZUISChBfaW'
    '50ZW5zaXR5X2FmdGVy');

@$core.Deprecated('Use thoughtRecordDescriptor instead')
const ThoughtRecord$json = {
  '1': 'ThoughtRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'event', '3': 2, '4': 1, '5': 9, '10': 'event'},
    {
      '1': 'occurred_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'alternative_view', '3': 4, '4': 1, '5': 9, '10': 'alternativeView'},
    {'1': 'feelings_now', '3': 5, '4': 1, '5': 9, '10': 'feelingsNow'},
    {
      '1': 'challenged_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'challengedAt',
      '17': true
    },
    {
      '1': 'thoughts',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.record.NegativeThought',
      '10': 'thoughts'
    },
    {
      '1': 'feelings',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.record.Feeling',
      '10': 'feelings'
    },
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'evidence_for_alternative',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'evidenceForAlternative'
    },
  ],
  '8': [
    {'1': '_occurred_at'},
    {'1': '_challenged_at'},
  ],
};

/// Descriptor for `ThoughtRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List thoughtRecordDescriptor = $convert.base64Decode(
    'Cg1UaG91Z2h0UmVjb3JkEg4KAmlkGAEgASgNUgJpZBIUCgVldmVudBgCIAEoCVIFZXZlbnQSQA'
    'oLb2NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSCm9jY3Vy'
    'cmVkQXSIAQESKQoQYWx0ZXJuYXRpdmVfdmlldxgEIAEoCVIPYWx0ZXJuYXRpdmVWaWV3EiEKDG'
    'ZlZWxpbmdzX25vdxgFIAEoCVILZmVlbGluZ3NOb3cSRAoNY2hhbGxlbmdlZF9hdBgGIAEoCzIa'
    'Lmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBIAVIMY2hhbGxlbmdlZEF0iAEBEjMKCHRob3VnaH'
    'RzGAcgAygLMhcucmVjb3JkLk5lZ2F0aXZlVGhvdWdodFIIdGhvdWdodHMSKwoIZmVlbGluZ3MY'
    'CCADKAsyDy5yZWNvcmQuRmVlbGluZ1IIZmVlbGluZ3MSOQoKY3JlYXRlZF9hdBgJIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAogASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0EjgKGGV2aWRlbmNlX2Zvcl'
    '9hbHRlcm5hdGl2ZRgLIAEoCVIWZXZpZGVuY2VGb3JBbHRlcm5hdGl2ZUIOCgxfb2NjdXJyZWRf'
    'YXRCEAoOX2NoYWxsZW5nZWRfYXQ=');

@$core.Deprecated('Use mapOfWorryDescriptor instead')
const MapOfWorry$json = {
  '1': 'MapOfWorry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'event', '3': 2, '4': 1, '5': 9, '10': 'event'},
    {
      '1': 'occurred_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'thoughts', '3': 4, '4': 1, '5': 9, '10': 'thoughts'},
    {
      '1': 'what_these_thoughts_mean',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'whatTheseThoughtsMean'
    },
    {
      '1': 'physical_sensations',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'physicalSensations'
    },
    {
      '1': 'resultant_behaviour',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'resultantBehaviour'
    },
    {
      '1': 'derived_from_id',
      '3': 8,
      '4': 1,
      '5': 13,
      '9': 1,
      '10': 'derivedFromId',
      '17': true
    },
    {
      '1': 'feelings',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.record.Feeling',
      '10': 'feelings'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
  '8': [
    {'1': '_occurred_at'},
    {'1': '_derived_from_id'},
  ],
};

/// Descriptor for `MapOfWorry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mapOfWorryDescriptor = $convert.base64Decode(
    'CgpNYXBPZldvcnJ5Eg4KAmlkGAEgASgNUgJpZBIUCgVldmVudBgCIAEoCVIFZXZlbnQSQAoLb2'
    'NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSCm9jY3VycmVk'
    'QXSIAQESGgoIdGhvdWdodHMYBCABKAlSCHRob3VnaHRzEjcKGHdoYXRfdGhlc2VfdGhvdWdodH'
    'NfbWVhbhgFIAEoCVIVd2hhdFRoZXNlVGhvdWdodHNNZWFuEi8KE3BoeXNpY2FsX3NlbnNhdGlv'
    'bnMYBiABKAlSEnBoeXNpY2FsU2Vuc2F0aW9ucxIvChNyZXN1bHRhbnRfYmVoYXZpb3VyGAcgAS'
    'gJUhJyZXN1bHRhbnRCZWhhdmlvdXISKwoPZGVyaXZlZF9mcm9tX2lkGAggASgNSAFSDWRlcml2'
    'ZWRGcm9tSWSIAQESKwoIZmVlbGluZ3MYCSADKAsyDy5yZWNvcmQuRmVlbGluZ1IIZmVlbGluZ3'
    'MSOQoKY3JlYXRlZF9hdBgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0'
    'ZWRBdBI5Cgp1cGRhdGVkX2F0GAsgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdX'
    'BkYXRlZEF0Qg4KDF9vY2N1cnJlZF9hdEISChBfZGVyaXZlZF9mcm9tX2lk');

@$core.Deprecated('Use behaviouralExperimentDescriptor instead')
const BehaviouralExperiment$json = {
  '1': 'BehaviouralExperiment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'plan', '3': 2, '4': 1, '5': 9, '10': 'plan'},
    {
      '1': 'occurred_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'prediction', '3': 4, '4': 1, '5': 9, '10': 'prediction'},
    {'1': 'outcome', '3': 5, '4': 1, '5': 9, '10': 'outcome'},
    {'1': 'learned', '3': 6, '4': 1, '5': 9, '10': 'learned'},
    {'1': 'build_on', '3': 7, '4': 1, '5': 9, '10': 'buildOn'},
    {
      '1': 'completed_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'completedAt',
      '17': true
    },
    {
      '1': 'feelings',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.record.Feeling',
      '10': 'feelings'
    },
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
  '8': [
    {'1': '_occurred_at'},
    {'1': '_completed_at'},
  ],
};

/// Descriptor for `BehaviouralExperiment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List behaviouralExperimentDescriptor = $convert.base64Decode(
    'ChVCZWhhdmlvdXJhbEV4cGVyaW1lbnQSDgoCaWQYASABKA1SAmlkEhIKBHBsYW4YAiABKAlSBH'
    'BsYW4SQAoLb2NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABS'
    'Cm9jY3VycmVkQXSIAQESHgoKcHJlZGljdGlvbhgEIAEoCVIKcHJlZGljdGlvbhIYCgdvdXRjb2'
    '1lGAUgASgJUgdvdXRjb21lEhgKB2xlYXJuZWQYBiABKAlSB2xlYXJuZWQSGQoIYnVpbGRfb24Y'
    'ByABKAlSB2J1aWxkT24SQgoMY29tcGxldGVkX2F0GAggASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcEgBUgtjb21wbGV0ZWRBdIgBARIrCghmZWVsaW5ncxgJIAMoCzIPLnJlY29yZC5G'
    'ZWVsaW5nUghmZWVsaW5ncxI5CgpjcmVhdGVkX2F0GAogASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYCyABKAsyGi5nb29nbGUucHJvdG9i'
    'dWYuVGltZXN0YW1wUgl1cGRhdGVkQXRCDgoMX29jY3VycmVkX2F0Qg8KDV9jb21wbGV0ZWRfYX'
    'Q=');

@$core.Deprecated('Use positiveDataLogDescriptor instead')
const PositiveDataLog$json = {
  '1': 'PositiveDataLog',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'belief', '3': 2, '4': 1, '5': 9, '10': 'belief'},
    {
      '1': 'alternative_belief',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'alternativeBelief'
    },
    {
      '1': 'evidence',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.record.DataLogEvidence',
      '10': 'evidence'
    },
    {
      '1': 'ratings',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.record.BeliefRating',
      '10': 'ratings'
    },
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `PositiveDataLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List positiveDataLogDescriptor = $convert.base64Decode(
    'Cg9Qb3NpdGl2ZURhdGFMb2cSDgoCaWQYASABKA1SAmlkEhYKBmJlbGllZhgCIAEoCVIGYmVsaW'
    'VmEi0KEmFsdGVybmF0aXZlX2JlbGllZhgDIAEoCVIRYWx0ZXJuYXRpdmVCZWxpZWYSMwoIZXZp'
    'ZGVuY2UYBCADKAsyFy5yZWNvcmQuRGF0YUxvZ0V2aWRlbmNlUghldmlkZW5jZRIuCgdyYXRpbm'
    'dzGAUgAygLMhQucmVjb3JkLkJlbGllZlJhdGluZ1IHcmF0aW5ncxI5CgpjcmVhdGVkX2F0GAYg'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYX'
    'QYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use dataLogEvidenceDescriptor instead')
const DataLogEvidence$json = {
  '1': 'DataLogEvidence',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {
      '1': 'noted_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'notedAt',
      '17': true
    },
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
  '8': [
    {'1': '_noted_at'},
  ],
};

/// Descriptor for `DataLogEvidence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataLogEvidenceDescriptor = $convert.base64Decode(
    'Cg9EYXRhTG9nRXZpZGVuY2USDgoCaWQYASABKA1SAmlkEhIKBGJvZHkYAiABKAlSBGJvZHkSOg'
    'oIbm90ZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSB25vdGVkQXSI'
    'AQESOQoKY3JlYXRlZF9hdBgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZW'
    'F0ZWRBdEILCglfbm90ZWRfYXQ=');

@$core.Deprecated('Use beliefRatingDescriptor instead')
const BeliefRating$json = {
  '1': 'BeliefRating',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {
      '1': 'rated_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'ratedAt'
    },
    {
      '1': 'belief_percent',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'beliefPercent',
      '17': true
    },
    {
      '1': 'alternative_percent',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'alternativePercent',
      '17': true
    },
  ],
  '8': [
    {'1': '_belief_percent'},
    {'1': '_alternative_percent'},
  ],
};

/// Descriptor for `BeliefRating`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List beliefRatingDescriptor = $convert.base64Decode(
    'CgxCZWxpZWZSYXRpbmcSDgoCaWQYASABKA1SAmlkEjUKCHJhdGVkX2F0GAIgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIHcmF0ZWRBdBIqCg5iZWxpZWZfcGVyY2VudBgDIAEoBUgA'
    'Ug1iZWxpZWZQZXJjZW50iAEBEjQKE2FsdGVybmF0aXZlX3BlcmNlbnQYBCABKAVIAVISYWx0ZX'
    'JuYXRpdmVQZXJjZW50iAEBQhEKD19iZWxpZWZfcGVyY2VudEIWChRfYWx0ZXJuYXRpdmVfcGVy'
    'Y2VudA==');

@$core.Deprecated('Use dataLogEvidenceInputDescriptor instead')
const DataLogEvidenceInput$json = {
  '1': 'DataLogEvidenceInput',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 9, '10': 'body'},
    {
      '1': 'noted_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'notedAt',
      '17': true
    },
  ],
  '8': [
    {'1': '_noted_at'},
  ],
};

/// Descriptor for `DataLogEvidenceInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataLogEvidenceInputDescriptor = $convert.base64Decode(
    'ChREYXRhTG9nRXZpZGVuY2VJbnB1dBISCgRib2R5GAEgASgJUgRib2R5EjoKCG5vdGVkX2F0GA'
    'IgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcEgAUgdub3RlZEF0iAEBQgsKCV9ub3Rl'
    'ZF9hdA==');

@$core.Deprecated('Use feelingInputDescriptor instead')
const FeelingInput$json = {
  '1': 'FeelingInput',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'intensity',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'intensity',
      '17': true
    },
  ],
  '8': [
    {'1': '_intensity'},
  ],
};

/// Descriptor for `FeelingInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feelingInputDescriptor = $convert.base64Decode(
    'CgxGZWVsaW5nSW5wdXQSEgoEbmFtZRgBIAEoCVIEbmFtZRIhCglpbnRlbnNpdHkYAiABKAVIAF'
    'IJaW50ZW5zaXR5iAEBQgwKCl9pbnRlbnNpdHk=');

@$core.Deprecated('Use thoughtInputDescriptor instead')
const ThoughtInput$json = {
  '1': 'ThoughtInput',
  '2': [
    {'1': 'body', '3': 1, '4': 1, '5': 9, '10': 'body'},
    {'1': 'is_hot', '3': 2, '4': 1, '5': 8, '10': 'isHot'},
    {'1': 'biases', '3': 3, '4': 3, '5': 9, '10': 'biases'},
    {'1': 'evidence', '3': 4, '4': 1, '5': 9, '10': 'evidence'},
  ],
};

/// Descriptor for `ThoughtInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List thoughtInputDescriptor = $convert.base64Decode(
    'CgxUaG91Z2h0SW5wdXQSEgoEYm9keRgBIAEoCVIEYm9keRIVCgZpc19ob3QYAiABKAhSBWlzSG'
    '90EhYKBmJpYXNlcxgDIAMoCVIGYmlhc2VzEhoKCGV2aWRlbmNlGAQgASgJUghldmlkZW5jZQ==');

@$core.Deprecated('Use listThoughtRecordsRequestDescriptor instead')
const ListThoughtRecordsRequest$json = {
  '1': 'ListThoughtRecordsRequest',
  '2': [
    {
      '1': 'challenged',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'challenged',
      '17': true
    },
    {
      '1': 'since',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'since',
      '17': true
    },
    {'1': 'search', '3': 3, '4': 1, '5': 9, '10': 'search'},
  ],
  '8': [
    {'1': '_challenged'},
    {'1': '_since'},
  ],
};

/// Descriptor for `ListThoughtRecordsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listThoughtRecordsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0VGhvdWdodFJlY29yZHNSZXF1ZXN0EiMKCmNoYWxsZW5nZWQYASABKAhIAFIKY2hhbG'
    'xlbmdlZIgBARI1CgVzaW5jZRgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBIAVIF'
    'c2luY2WIAQESFgoGc2VhcmNoGAMgASgJUgZzZWFyY2hCDQoLX2NoYWxsZW5nZWRCCAoGX3Npbm'
    'Nl');

@$core.Deprecated('Use listThoughtRecordsResponseDescriptor instead')
const ListThoughtRecordsResponse$json = {
  '1': 'ListThoughtRecordsResponse',
  '2': [
    {
      '1': 'records',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.record.ThoughtRecord',
      '10': 'records'
    },
  ],
};

/// Descriptor for `ListThoughtRecordsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listThoughtRecordsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0VGhvdWdodFJlY29yZHNSZXNwb25zZRIvCgdyZWNvcmRzGAEgAygLMhUucmVjb3JkLl'
        'Rob3VnaHRSZWNvcmRSB3JlY29yZHM=');

@$core.Deprecated('Use createThoughtRecordRequestDescriptor instead')
const CreateThoughtRecordRequest$json = {
  '1': 'CreateThoughtRecordRequest',
  '2': [
    {'1': 'event', '3': 1, '4': 1, '5': 9, '10': 'event'},
    {
      '1': 'occurred_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'alternative_view', '3': 3, '4': 1, '5': 9, '10': 'alternativeView'},
    {'1': 'feelings_now', '3': 4, '4': 1, '5': 9, '10': 'feelingsNow'},
    {
      '1': 'thoughts',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.record.ThoughtInput',
      '10': 'thoughts'
    },
    {
      '1': 'feelings',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'feelings'
    },
    {
      '1': 'evidence_for_alternative',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'evidenceForAlternative'
    },
  ],
  '8': [
    {'1': '_occurred_at'},
  ],
};

/// Descriptor for `CreateThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createThoughtRecordRequestDescriptor = $convert.base64Decode(
    'ChpDcmVhdGVUaG91Z2h0UmVjb3JkUmVxdWVzdBIUCgVldmVudBgBIAEoCVIFZXZlbnQSQAoLb2'
    'NjdXJyZWRfYXQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSCm9jY3VycmVk'
    'QXSIAQESKQoQYWx0ZXJuYXRpdmVfdmlldxgDIAEoCVIPYWx0ZXJuYXRpdmVWaWV3EiEKDGZlZW'
    'xpbmdzX25vdxgEIAEoCVILZmVlbGluZ3NOb3cSMAoIdGhvdWdodHMYBSADKAsyFC5yZWNvcmQu'
    'VGhvdWdodElucHV0Ugh0aG91Z2h0cxIwCghmZWVsaW5ncxgGIAMoCzIULnJlY29yZC5GZWVsaW'
    '5nSW5wdXRSCGZlZWxpbmdzEjgKGGV2aWRlbmNlX2Zvcl9hbHRlcm5hdGl2ZRgHIAEoCVIWZXZp'
    'ZGVuY2VGb3JBbHRlcm5hdGl2ZUIOCgxfb2NjdXJyZWRfYXQ=');

@$core.Deprecated('Use getThoughtRecordRequestDescriptor instead')
const GetThoughtRecordRequest$json = {
  '1': 'GetThoughtRecordRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `GetThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getThoughtRecordRequestDescriptor = $convert
    .base64Decode('ChdHZXRUaG91Z2h0UmVjb3JkUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use updateThoughtRecordRequestDescriptor instead')
const UpdateThoughtRecordRequest$json = {
  '1': 'UpdateThoughtRecordRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'event', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'event', '17': true},
    {
      '1': 'occurred_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'clear_occurred_at', '3': 4, '4': 1, '5': 8, '10': 'clearOccurredAt'},
    {
      '1': 'alternative_view',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'alternativeView',
      '17': true
    },
    {
      '1': 'feelings_now',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'feelingsNow',
      '17': true
    },
    {
      '1': 'evidence_for_alternative',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'evidenceForAlternative',
      '17': true
    },
  ],
  '8': [
    {'1': '_event'},
    {'1': '_occurred_at'},
    {'1': '_alternative_view'},
    {'1': '_feelings_now'},
    {'1': '_evidence_for_alternative'},
  ],
};

/// Descriptor for `UpdateThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateThoughtRecordRequestDescriptor = $convert.base64Decode(
    'ChpVcGRhdGVUaG91Z2h0UmVjb3JkUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSGQoFZXZlbnQYAi'
    'ABKAlIAFIFZXZlbnSIAQESQAoLb2NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'VGltZXN0YW1wSAFSCm9jY3VycmVkQXSIAQESKgoRY2xlYXJfb2NjdXJyZWRfYXQYBCABKAhSD2'
    'NsZWFyT2NjdXJyZWRBdBIuChBhbHRlcm5hdGl2ZV92aWV3GAUgASgJSAJSD2FsdGVybmF0aXZl'
    'Vmlld4gBARImCgxmZWVsaW5nc19ub3cYBiABKAlIA1ILZmVlbGluZ3NOb3eIAQESPQoYZXZpZG'
    'VuY2VfZm9yX2FsdGVybmF0aXZlGAcgASgJSARSFmV2aWRlbmNlRm9yQWx0ZXJuYXRpdmWIAQFC'
    'CAoGX2V2ZW50Qg4KDF9vY2N1cnJlZF9hdEITChFfYWx0ZXJuYXRpdmVfdmlld0IPCg1fZmVlbG'
    'luZ3Nfbm93QhsKGV9ldmlkZW5jZV9mb3JfYWx0ZXJuYXRpdmU=');

@$core.Deprecated('Use thoughtJudgementDescriptor instead')
const ThoughtJudgement$json = {
  '1': 'ThoughtJudgement',
  '2': [
    {'1': 'thought_id', '3': 1, '4': 1, '5': 13, '10': 'thoughtId'},
    {
      '1': 'biases',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.BiasNames',
      '9': 0,
      '10': 'biases',
      '17': true
    },
    {
      '1': 'is_factual',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'isFactual',
      '17': true
    },
    {
      '1': 'belief_after',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 2,
      '10': 'beliefAfter',
      '17': true
    },
  ],
  '8': [
    {'1': '_biases'},
    {'1': '_is_factual'},
    {'1': '_belief_after'},
  ],
};

/// Descriptor for `ThoughtJudgement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List thoughtJudgementDescriptor = $convert.base64Decode(
    'ChBUaG91Z2h0SnVkZ2VtZW50Eh0KCnRob3VnaHRfaWQYASABKA1SCXRob3VnaHRJZBIuCgZiaW'
    'FzZXMYAiABKAsyES5yZWNvcmQuQmlhc05hbWVzSABSBmJpYXNlc4gBARIiCgppc19mYWN0dWFs'
    'GAMgASgISAFSCWlzRmFjdHVhbIgBARImCgxiZWxpZWZfYWZ0ZXIYBCABKAVIAlILYmVsaWVmQW'
    'Z0ZXKIAQFCCQoHX2JpYXNlc0INCgtfaXNfZmFjdHVhbEIPCg1fYmVsaWVmX2FmdGVy');

@$core.Deprecated('Use feelingReratingDescriptor instead')
const FeelingRerating$json = {
  '1': 'FeelingRerating',
  '2': [
    {'1': 'feeling_id', '3': 1, '4': 1, '5': 13, '10': 'feelingId'},
    {'1': 'intensity_after', '3': 2, '4': 1, '5': 5, '10': 'intensityAfter'},
  ],
};

/// Descriptor for `FeelingRerating`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List feelingReratingDescriptor = $convert.base64Decode(
    'Cg9GZWVsaW5nUmVyYXRpbmcSHQoKZmVlbGluZ19pZBgBIAEoDVIJZmVlbGluZ0lkEicKD2ludG'
    'Vuc2l0eV9hZnRlchgCIAEoBVIOaW50ZW5zaXR5QWZ0ZXI=');

@$core.Deprecated('Use challengeThoughtRecordRequestDescriptor instead')
const ChallengeThoughtRecordRequest$json = {
  '1': 'ChallengeThoughtRecordRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'alternative_view', '3': 2, '4': 1, '5': 9, '10': 'alternativeView'},
    {'1': 'feelings_now', '3': 3, '4': 1, '5': 9, '10': 'feelingsNow'},
    {
      '1': 'feeling_reratings',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.record.FeelingRerating',
      '10': 'feelingReratings'
    },
    {
      '1': 'thoughts',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.record.ThoughtJudgement',
      '10': 'thoughts'
    },
    {
      '1': 'evidence_for_alternative',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'evidenceForAlternative'
    },
  ],
};

/// Descriptor for `ChallengeThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List challengeThoughtRecordRequestDescriptor = $convert.base64Decode(
    'Ch1DaGFsbGVuZ2VUaG91Z2h0UmVjb3JkUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSKQoQYWx0ZX'
    'JuYXRpdmVfdmlldxgCIAEoCVIPYWx0ZXJuYXRpdmVWaWV3EiEKDGZlZWxpbmdzX25vdxgDIAEo'
    'CVILZmVlbGluZ3NOb3cSRAoRZmVlbGluZ19yZXJhdGluZ3MYBCADKAsyFy5yZWNvcmQuRmVlbG'
    'luZ1JlcmF0aW5nUhBmZWVsaW5nUmVyYXRpbmdzEjQKCHRob3VnaHRzGAUgAygLMhgucmVjb3Jk'
    'LlRob3VnaHRKdWRnZW1lbnRSCHRob3VnaHRzEjgKGGV2aWRlbmNlX2Zvcl9hbHRlcm5hdGl2ZR'
    'gGIAEoCVIWZXZpZGVuY2VGb3JBbHRlcm5hdGl2ZQ==');

@$core.Deprecated('Use deleteThoughtRecordRequestDescriptor instead')
const DeleteThoughtRecordRequest$json = {
  '1': 'DeleteThoughtRecordRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteThoughtRecordRequestDescriptor =
    $convert.base64Decode(
        'ChpEZWxldGVUaG91Z2h0UmVjb3JkUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use addThoughtRequestDescriptor instead')
const AddThoughtRequest$json = {
  '1': 'AddThoughtRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 13, '10': 'recordId'},
    {
      '1': 'thought',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.ThoughtInput',
      '10': 'thought'
    },
  ],
};

/// Descriptor for `AddThoughtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addThoughtRequestDescriptor = $convert.base64Decode(
    'ChFBZGRUaG91Z2h0UmVxdWVzdBIbCglyZWNvcmRfaWQYASABKA1SCHJlY29yZElkEi4KB3Rob3'
    'VnaHQYAiABKAsyFC5yZWNvcmQuVGhvdWdodElucHV0Ugd0aG91Z2h0');

@$core.Deprecated('Use updateThoughtRequestDescriptor instead')
const UpdateThoughtRequest$json = {
  '1': 'UpdateThoughtRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'body', '3': 2, '4': 1, '5': 9, '10': 'body'},
    {
      '1': 'biases',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.record.BiasNames',
      '9': 0,
      '10': 'biases',
      '17': true
    },
  ],
  '8': [
    {'1': '_biases'},
  ],
};

/// Descriptor for `UpdateThoughtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateThoughtRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVUaG91Z2h0UmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSEgoEYm9keRgCIAEoCVIEYm'
    '9keRIuCgZiaWFzZXMYAyABKAsyES5yZWNvcmQuQmlhc05hbWVzSABSBmJpYXNlc4gBAUIJCgdf'
    'Ymlhc2Vz');

@$core.Deprecated('Use biasNamesDescriptor instead')
const BiasNames$json = {
  '1': 'BiasNames',
  '2': [
    {'1': 'names', '3': 1, '4': 3, '5': 9, '10': 'names'},
  ],
};

/// Descriptor for `BiasNames`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List biasNamesDescriptor =
    $convert.base64Decode('CglCaWFzTmFtZXMSFAoFbmFtZXMYASADKAlSBW5hbWVz');

@$core.Deprecated('Use setHotThoughtRequestDescriptor instead')
const SetHotThoughtRequest$json = {
  '1': 'SetHotThoughtRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `SetHotThoughtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setHotThoughtRequestDescriptor = $convert
    .base64Decode('ChRTZXRIb3RUaG91Z2h0UmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use setThoughtFactualRequestDescriptor instead')
const SetThoughtFactualRequest$json = {
  '1': 'SetThoughtFactualRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'factual', '3': 2, '4': 1, '5': 8, '10': 'factual'},
  ],
};

/// Descriptor for `SetThoughtFactualRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setThoughtFactualRequestDescriptor =
    $convert.base64Decode(
        'ChhTZXRUaG91Z2h0RmFjdHVhbFJlcXVlc3QSDgoCaWQYASABKA1SAmlkEhgKB2ZhY3R1YWwYAi'
        'ABKAhSB2ZhY3R1YWw=');

@$core.Deprecated('Use setThoughtEvidenceRequestDescriptor instead')
const SetThoughtEvidenceRequest$json = {
  '1': 'SetThoughtEvidenceRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'evidence', '3': 2, '4': 1, '5': 9, '10': 'evidence'},
  ],
};

/// Descriptor for `SetThoughtEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setThoughtEvidenceRequestDescriptor =
    $convert.base64Decode(
        'ChlTZXRUaG91Z2h0RXZpZGVuY2VSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZBIaCghldmlkZW5jZR'
        'gCIAEoCVIIZXZpZGVuY2U=');

@$core.Deprecated('Use deleteThoughtRequestDescriptor instead')
const DeleteThoughtRequest$json = {
  '1': 'DeleteThoughtRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteThoughtRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteThoughtRequestDescriptor = $convert
    .base64Decode('ChREZWxldGVUaG91Z2h0UmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use addFeelingRequestDescriptor instead')
const AddFeelingRequest$json = {
  '1': 'AddFeelingRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 13, '10': 'recordId'},
    {
      '1': 'feeling',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'feeling'
    },
  ],
};

/// Descriptor for `AddFeelingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addFeelingRequestDescriptor = $convert.base64Decode(
    'ChFBZGRGZWVsaW5nUmVxdWVzdBIbCglyZWNvcmRfaWQYASABKA1SCHJlY29yZElkEi4KB2ZlZW'
    'xpbmcYAiABKAsyFC5yZWNvcmQuRmVlbGluZ0lucHV0UgdmZWVsaW5n');

@$core.Deprecated('Use addMapFeelingRequestDescriptor instead')
const AddMapFeelingRequest$json = {
  '1': 'AddMapFeelingRequest',
  '2': [
    {'1': 'map_id', '3': 1, '4': 1, '5': 13, '10': 'mapId'},
    {
      '1': 'feeling',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'feeling'
    },
  ],
};

/// Descriptor for `AddMapFeelingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMapFeelingRequestDescriptor = $convert.base64Decode(
    'ChRBZGRNYXBGZWVsaW5nUmVxdWVzdBIVCgZtYXBfaWQYASABKA1SBW1hcElkEi4KB2ZlZWxpbm'
    'cYAiABKAsyFC5yZWNvcmQuRmVlbGluZ0lucHV0UgdmZWVsaW5n');

@$core.Deprecated('Use deleteFeelingRequestDescriptor instead')
const DeleteFeelingRequest$json = {
  '1': 'DeleteFeelingRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteFeelingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFeelingRequestDescriptor = $convert
    .base64Decode('ChREZWxldGVGZWVsaW5nUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use listMapsOfWorryRequestDescriptor instead')
const ListMapsOfWorryRequest$json = {
  '1': 'ListMapsOfWorryRequest',
  '2': [
    {
      '1': 'since',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'since',
      '17': true
    },
    {'1': 'search', '3': 2, '4': 1, '5': 9, '10': 'search'},
  ],
  '8': [
    {'1': '_since'},
  ],
};

/// Descriptor for `ListMapsOfWorryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMapsOfWorryRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0TWFwc09mV29ycnlSZXF1ZXN0EjUKBXNpbmNlGAEgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcEgAUgVzaW5jZYgBARIWCgZzZWFyY2gYAiABKAlSBnNlYXJjaEIICgZfc2lu'
    'Y2U=');

@$core.Deprecated('Use listMapsOfWorryResponseDescriptor instead')
const ListMapsOfWorryResponse$json = {
  '1': 'ListMapsOfWorryResponse',
  '2': [
    {
      '1': 'maps',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.record.MapOfWorry',
      '10': 'maps'
    },
  ],
};

/// Descriptor for `ListMapsOfWorryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMapsOfWorryResponseDescriptor =
    $convert.base64Decode(
        'ChdMaXN0TWFwc09mV29ycnlSZXNwb25zZRImCgRtYXBzGAEgAygLMhIucmVjb3JkLk1hcE9mV2'
        '9ycnlSBG1hcHM=');

@$core.Deprecated('Use createMapOfWorryRequestDescriptor instead')
const CreateMapOfWorryRequest$json = {
  '1': 'CreateMapOfWorryRequest',
  '2': [
    {'1': 'event', '3': 1, '4': 1, '5': 9, '10': 'event'},
    {
      '1': 'occurred_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'thoughts', '3': 3, '4': 1, '5': 9, '10': 'thoughts'},
    {
      '1': 'what_these_thoughts_mean',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'whatTheseThoughtsMean'
    },
    {
      '1': 'physical_sensations',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'physicalSensations'
    },
    {
      '1': 'resultant_behaviour',
      '3': 6,
      '4': 1,
      '5': 9,
      '10': 'resultantBehaviour'
    },
    {
      '1': 'derived_from_id',
      '3': 7,
      '4': 1,
      '5': 13,
      '9': 1,
      '10': 'derivedFromId',
      '17': true
    },
    {
      '1': 'feelings',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'feelings'
    },
  ],
  '8': [
    {'1': '_occurred_at'},
    {'1': '_derived_from_id'},
  ],
};

/// Descriptor for `CreateMapOfWorryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createMapOfWorryRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVNYXBPZldvcnJ5UmVxdWVzdBIUCgVldmVudBgBIAEoCVIFZXZlbnQSQAoLb2NjdX'
    'JyZWRfYXQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSCm9jY3VycmVkQXSI'
    'AQESGgoIdGhvdWdodHMYAyABKAlSCHRob3VnaHRzEjcKGHdoYXRfdGhlc2VfdGhvdWdodHNfbW'
    'VhbhgEIAEoCVIVd2hhdFRoZXNlVGhvdWdodHNNZWFuEi8KE3BoeXNpY2FsX3NlbnNhdGlvbnMY'
    'BSABKAlSEnBoeXNpY2FsU2Vuc2F0aW9ucxIvChNyZXN1bHRhbnRfYmVoYXZpb3VyGAYgASgJUh'
    'JyZXN1bHRhbnRCZWhhdmlvdXISKwoPZGVyaXZlZF9mcm9tX2lkGAcgASgNSAFSDWRlcml2ZWRG'
    'cm9tSWSIAQESMAoIZmVlbGluZ3MYCCADKAsyFC5yZWNvcmQuRmVlbGluZ0lucHV0UghmZWVsaW'
    '5nc0IOCgxfb2NjdXJyZWRfYXRCEgoQX2Rlcml2ZWRfZnJvbV9pZA==');

@$core.Deprecated('Use getMapOfWorryRequestDescriptor instead')
const GetMapOfWorryRequest$json = {
  '1': 'GetMapOfWorryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `GetMapOfWorryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMapOfWorryRequestDescriptor = $convert
    .base64Decode('ChRHZXRNYXBPZldvcnJ5UmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use getMapOfWorryResponseDescriptor instead')
const GetMapOfWorryResponse$json = {
  '1': 'GetMapOfWorryResponse',
  '2': [
    {
      '1': 'map',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.record.MapOfWorry',
      '10': 'map'
    },
    {
      '1': 'derived_from',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.MapOfWorry',
      '9': 0,
      '10': 'derivedFrom',
      '17': true
    },
    {
      '1': 'alternatives',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.record.MapOfWorry',
      '10': 'alternatives'
    },
  ],
  '8': [
    {'1': '_derived_from'},
  ],
};

/// Descriptor for `GetMapOfWorryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMapOfWorryResponseDescriptor = $convert.base64Decode(
    'ChVHZXRNYXBPZldvcnJ5UmVzcG9uc2USJAoDbWFwGAEgASgLMhIucmVjb3JkLk1hcE9mV29ycn'
    'lSA21hcBI6CgxkZXJpdmVkX2Zyb20YAiABKAsyEi5yZWNvcmQuTWFwT2ZXb3JyeUgAUgtkZXJp'
    'dmVkRnJvbYgBARI2CgxhbHRlcm5hdGl2ZXMYAyADKAsyEi5yZWNvcmQuTWFwT2ZXb3JyeVIMYW'
    'x0ZXJuYXRpdmVzQg8KDV9kZXJpdmVkX2Zyb20=');

@$core.Deprecated('Use updateMapOfWorryRequestDescriptor instead')
const UpdateMapOfWorryRequest$json = {
  '1': 'UpdateMapOfWorryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'event', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'event', '17': true},
    {
      '1': 'occurred_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'clear_occurred_at', '3': 4, '4': 1, '5': 8, '10': 'clearOccurredAt'},
    {
      '1': 'thoughts',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'thoughts',
      '17': true
    },
    {
      '1': 'what_these_thoughts_mean',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'whatTheseThoughtsMean',
      '17': true
    },
    {
      '1': 'physical_sensations',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'physicalSensations',
      '17': true
    },
    {
      '1': 'resultant_behaviour',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'resultantBehaviour',
      '17': true
    },
  ],
  '8': [
    {'1': '_event'},
    {'1': '_occurred_at'},
    {'1': '_thoughts'},
    {'1': '_what_these_thoughts_mean'},
    {'1': '_physical_sensations'},
    {'1': '_resultant_behaviour'},
  ],
};

/// Descriptor for `UpdateMapOfWorryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateMapOfWorryRequestDescriptor = $convert.base64Decode(
    'ChdVcGRhdGVNYXBPZldvcnJ5UmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSGQoFZXZlbnQYAiABKA'
    'lIAFIFZXZlbnSIAQESQAoLb2NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGlt'
    'ZXN0YW1wSAFSCm9jY3VycmVkQXSIAQESKgoRY2xlYXJfb2NjdXJyZWRfYXQYBCABKAhSD2NsZW'
    'FyT2NjdXJyZWRBdBIfCgh0aG91Z2h0cxgFIAEoCUgCUgh0aG91Z2h0c4gBARI8Chh3aGF0X3Ro'
    'ZXNlX3Rob3VnaHRzX21lYW4YBiABKAlIA1IVd2hhdFRoZXNlVGhvdWdodHNNZWFuiAEBEjQKE3'
    'BoeXNpY2FsX3NlbnNhdGlvbnMYByABKAlIBFIScGh5c2ljYWxTZW5zYXRpb25ziAEBEjQKE3Jl'
    'c3VsdGFudF9iZWhhdmlvdXIYCCABKAlIBVIScmVzdWx0YW50QmVoYXZpb3VyiAEBQggKBl9ldm'
    'VudEIOCgxfb2NjdXJyZWRfYXRCCwoJX3Rob3VnaHRzQhsKGV93aGF0X3RoZXNlX3Rob3VnaHRz'
    'X21lYW5CFgoUX3BoeXNpY2FsX3NlbnNhdGlvbnNCFgoUX3Jlc3VsdGFudF9iZWhhdmlvdXI=');

@$core.Deprecated('Use deleteMapOfWorryRequestDescriptor instead')
const DeleteMapOfWorryRequest$json = {
  '1': 'DeleteMapOfWorryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteMapOfWorryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteMapOfWorryRequestDescriptor = $convert
    .base64Decode('ChdEZWxldGVNYXBPZldvcnJ5UmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');

@$core.Deprecated('Use listBehaviouralExperimentsRequestDescriptor instead')
const ListBehaviouralExperimentsRequest$json = {
  '1': 'ListBehaviouralExperimentsRequest',
  '2': [
    {
      '1': 'completed',
      '3': 1,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'completed',
      '17': true
    },
    {
      '1': 'since',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'since',
      '17': true
    },
    {'1': 'search', '3': 3, '4': 1, '5': 9, '10': 'search'},
  ],
  '8': [
    {'1': '_completed'},
    {'1': '_since'},
  ],
};

/// Descriptor for `ListBehaviouralExperimentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBehaviouralExperimentsRequestDescriptor =
    $convert.base64Decode(
        'CiFMaXN0QmVoYXZpb3VyYWxFeHBlcmltZW50c1JlcXVlc3QSIQoJY29tcGxldGVkGAEgASgISA'
        'BSCWNvbXBsZXRlZIgBARI1CgVzaW5jZRgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3Rh'
        'bXBIAVIFc2luY2WIAQESFgoGc2VhcmNoGAMgASgJUgZzZWFyY2hCDAoKX2NvbXBsZXRlZEIICg'
        'Zfc2luY2U=');

@$core.Deprecated('Use listBehaviouralExperimentsResponseDescriptor instead')
const ListBehaviouralExperimentsResponse$json = {
  '1': 'ListBehaviouralExperimentsResponse',
  '2': [
    {
      '1': 'experiments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.record.BehaviouralExperiment',
      '10': 'experiments'
    },
  ],
};

/// Descriptor for `ListBehaviouralExperimentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBehaviouralExperimentsResponseDescriptor =
    $convert.base64Decode(
        'CiJMaXN0QmVoYXZpb3VyYWxFeHBlcmltZW50c1Jlc3BvbnNlEj8KC2V4cGVyaW1lbnRzGAEgAy'
        'gLMh0ucmVjb3JkLkJlaGF2aW91cmFsRXhwZXJpbWVudFILZXhwZXJpbWVudHM=');

@$core.Deprecated('Use createBehaviouralExperimentRequestDescriptor instead')
const CreateBehaviouralExperimentRequest$json = {
  '1': 'CreateBehaviouralExperimentRequest',
  '2': [
    {'1': 'plan', '3': 1, '4': 1, '5': 9, '10': 'plan'},
    {
      '1': 'occurred_at',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 0,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'prediction', '3': 3, '4': 1, '5': 9, '10': 'prediction'},
    {
      '1': 'feelings',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'feelings'
    },
  ],
  '8': [
    {'1': '_occurred_at'},
  ],
};

/// Descriptor for `CreateBehaviouralExperimentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBehaviouralExperimentRequestDescriptor =
    $convert.base64Decode(
        'CiJDcmVhdGVCZWhhdmlvdXJhbEV4cGVyaW1lbnRSZXF1ZXN0EhIKBHBsYW4YASABKAlSBHBsYW'
        '4SQAoLb2NjdXJyZWRfYXQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wSABSCm9j'
        'Y3VycmVkQXSIAQESHgoKcHJlZGljdGlvbhgDIAEoCVIKcHJlZGljdGlvbhIwCghmZWVsaW5ncx'
        'gEIAMoCzIULnJlY29yZC5GZWVsaW5nSW5wdXRSCGZlZWxpbmdzQg4KDF9vY2N1cnJlZF9hdA==');

@$core.Deprecated('Use getBehaviouralExperimentRequestDescriptor instead')
const GetBehaviouralExperimentRequest$json = {
  '1': 'GetBehaviouralExperimentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `GetBehaviouralExperimentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBehaviouralExperimentRequestDescriptor =
    $convert.base64Decode(
        'Ch9HZXRCZWhhdmlvdXJhbEV4cGVyaW1lbnRSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZA==');

@$core.Deprecated('Use updateBehaviouralExperimentRequestDescriptor instead')
const UpdateBehaviouralExperimentRequest$json = {
  '1': 'UpdateBehaviouralExperimentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'plan', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'plan', '17': true},
    {
      '1': 'occurred_at',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 1,
      '10': 'occurredAt',
      '17': true
    },
    {'1': 'clear_occurred_at', '3': 4, '4': 1, '5': 8, '10': 'clearOccurredAt'},
    {
      '1': 'prediction',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'prediction',
      '17': true
    },
    {
      '1': 'outcome',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'outcome',
      '17': true
    },
    {
      '1': 'learned',
      '3': 7,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'learned',
      '17': true
    },
    {
      '1': 'build_on',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'buildOn',
      '17': true
    },
  ],
  '8': [
    {'1': '_plan'},
    {'1': '_occurred_at'},
    {'1': '_prediction'},
    {'1': '_outcome'},
    {'1': '_learned'},
    {'1': '_build_on'},
  ],
};

/// Descriptor for `UpdateBehaviouralExperimentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateBehaviouralExperimentRequestDescriptor = $convert.base64Decode(
    'CiJVcGRhdGVCZWhhdmlvdXJhbEV4cGVyaW1lbnRSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZBIXCg'
    'RwbGFuGAIgASgJSABSBHBsYW6IAQESQAoLb2NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wSAFSCm9jY3VycmVkQXSIAQESKgoRY2xlYXJfb2NjdXJyZWRfYXQYBC'
    'ABKAhSD2NsZWFyT2NjdXJyZWRBdBIjCgpwcmVkaWN0aW9uGAUgASgJSAJSCnByZWRpY3Rpb26I'
    'AQESHQoHb3V0Y29tZRgGIAEoCUgDUgdvdXRjb21liAEBEh0KB2xlYXJuZWQYByABKAlIBFIHbG'
    'Vhcm5lZIgBARIeCghidWlsZF9vbhgIIAEoCUgFUgdidWlsZE9uiAEBQgcKBV9wbGFuQg4KDF9v'
    'Y2N1cnJlZF9hdEINCgtfcHJlZGljdGlvbkIKCghfb3V0Y29tZUIKCghfbGVhcm5lZEILCglfYn'
    'VpbGRfb24=');

@$core.Deprecated('Use completeBehaviouralExperimentRequestDescriptor instead')
const CompleteBehaviouralExperimentRequest$json = {
  '1': 'CompleteBehaviouralExperimentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'outcome', '3': 2, '4': 1, '5': 9, '10': 'outcome'},
    {'1': 'learned', '3': 3, '4': 1, '5': 9, '10': 'learned'},
    {'1': 'build_on', '3': 4, '4': 1, '5': 9, '10': 'buildOn'},
    {
      '1': 'feeling_reratings',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.record.FeelingRerating',
      '10': 'feelingReratings'
    },
    {
      '1': 'new_feelings',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'newFeelings'
    },
  ],
};

/// Descriptor for `CompleteBehaviouralExperimentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List completeBehaviouralExperimentRequestDescriptor =
    $convert.base64Decode(
        'CiRDb21wbGV0ZUJlaGF2aW91cmFsRXhwZXJpbWVudFJlcXVlc3QSDgoCaWQYASABKA1SAmlkEh'
        'gKB291dGNvbWUYAiABKAlSB291dGNvbWUSGAoHbGVhcm5lZBgDIAEoCVIHbGVhcm5lZBIZCghi'
        'dWlsZF9vbhgEIAEoCVIHYnVpbGRPbhJEChFmZWVsaW5nX3JlcmF0aW5ncxgFIAMoCzIXLnJlY2'
        '9yZC5GZWVsaW5nUmVyYXRpbmdSEGZlZWxpbmdSZXJhdGluZ3MSNwoMbmV3X2ZlZWxpbmdzGAYg'
        'AygLMhQucmVjb3JkLkZlZWxpbmdJbnB1dFILbmV3RmVlbGluZ3M=');

@$core.Deprecated('Use deleteBehaviouralExperimentRequestDescriptor instead')
const DeleteBehaviouralExperimentRequest$json = {
  '1': 'DeleteBehaviouralExperimentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteBehaviouralExperimentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteBehaviouralExperimentRequestDescriptor =
    $convert.base64Decode(
        'CiJEZWxldGVCZWhhdmlvdXJhbEV4cGVyaW1lbnRSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZA==');

@$core.Deprecated('Use addExperimentFeelingRequestDescriptor instead')
const AddExperimentFeelingRequest$json = {
  '1': 'AddExperimentFeelingRequest',
  '2': [
    {'1': 'experiment_id', '3': 1, '4': 1, '5': 13, '10': 'experimentId'},
    {
      '1': 'feeling',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.FeelingInput',
      '10': 'feeling'
    },
  ],
};

/// Descriptor for `AddExperimentFeelingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addExperimentFeelingRequestDescriptor =
    $convert.base64Decode(
        'ChtBZGRFeHBlcmltZW50RmVlbGluZ1JlcXVlc3QSIwoNZXhwZXJpbWVudF9pZBgBIAEoDVIMZX'
        'hwZXJpbWVudElkEi4KB2ZlZWxpbmcYAiABKAsyFC5yZWNvcmQuRmVlbGluZ0lucHV0UgdmZWVs'
        'aW5n');

@$core.Deprecated('Use listPositiveDataLogsRequestDescriptor instead')
const ListPositiveDataLogsRequest$json = {
  '1': 'ListPositiveDataLogsRequest',
  '2': [
    {'1': 'search', '3': 1, '4': 1, '5': 9, '10': 'search'},
  ],
};

/// Descriptor for `ListPositiveDataLogsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPositiveDataLogsRequestDescriptor =
    $convert.base64Decode(
        'ChtMaXN0UG9zaXRpdmVEYXRhTG9nc1JlcXVlc3QSFgoGc2VhcmNoGAEgASgJUgZzZWFyY2g=');

@$core.Deprecated('Use listPositiveDataLogsResponseDescriptor instead')
const ListPositiveDataLogsResponse$json = {
  '1': 'ListPositiveDataLogsResponse',
  '2': [
    {
      '1': 'logs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.record.PositiveDataLog',
      '10': 'logs'
    },
  ],
};

/// Descriptor for `ListPositiveDataLogsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPositiveDataLogsResponseDescriptor =
    $convert.base64Decode(
        'ChxMaXN0UG9zaXRpdmVEYXRhTG9nc1Jlc3BvbnNlEisKBGxvZ3MYASADKAsyFy5yZWNvcmQuUG'
        '9zaXRpdmVEYXRhTG9nUgRsb2dz');

@$core.Deprecated('Use createPositiveDataLogRequestDescriptor instead')
const CreatePositiveDataLogRequest$json = {
  '1': 'CreatePositiveDataLogRequest',
  '2': [
    {'1': 'belief', '3': 1, '4': 1, '5': 9, '10': 'belief'},
    {
      '1': 'alternative_belief',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'alternativeBelief'
    },
    {
      '1': 'belief_percent',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'beliefPercent',
      '17': true
    },
    {
      '1': 'alternative_percent',
      '3': 4,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'alternativePercent',
      '17': true
    },
    {
      '1': 'evidence',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.record.DataLogEvidenceInput',
      '10': 'evidence'
    },
  ],
  '8': [
    {'1': '_belief_percent'},
    {'1': '_alternative_percent'},
  ],
};

/// Descriptor for `CreatePositiveDataLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPositiveDataLogRequestDescriptor = $convert.base64Decode(
    'ChxDcmVhdGVQb3NpdGl2ZURhdGFMb2dSZXF1ZXN0EhYKBmJlbGllZhgBIAEoCVIGYmVsaWVmEi'
    '0KEmFsdGVybmF0aXZlX2JlbGllZhgCIAEoCVIRYWx0ZXJuYXRpdmVCZWxpZWYSKgoOYmVsaWVm'
    'X3BlcmNlbnQYAyABKAVIAFINYmVsaWVmUGVyY2VudIgBARI0ChNhbHRlcm5hdGl2ZV9wZXJjZW'
    '50GAQgASgFSAFSEmFsdGVybmF0aXZlUGVyY2VudIgBARI4CghldmlkZW5jZRgFIAMoCzIcLnJl'
    'Y29yZC5EYXRhTG9nRXZpZGVuY2VJbnB1dFIIZXZpZGVuY2VCEQoPX2JlbGllZl9wZXJjZW50Qh'
    'YKFF9hbHRlcm5hdGl2ZV9wZXJjZW50');

@$core.Deprecated('Use getPositiveDataLogRequestDescriptor instead')
const GetPositiveDataLogRequest$json = {
  '1': 'GetPositiveDataLogRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `GetPositiveDataLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPositiveDataLogRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRQb3NpdGl2ZURhdGFMb2dSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZA==');

@$core.Deprecated('Use updatePositiveDataLogRequestDescriptor instead')
const UpdatePositiveDataLogRequest$json = {
  '1': 'UpdatePositiveDataLogRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'belief', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'belief', '17': true},
    {
      '1': 'alternative_belief',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'alternativeBelief',
      '17': true
    },
  ],
  '8': [
    {'1': '_belief'},
    {'1': '_alternative_belief'},
  ],
};

/// Descriptor for `UpdatePositiveDataLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePositiveDataLogRequestDescriptor =
    $convert.base64Decode(
        'ChxVcGRhdGVQb3NpdGl2ZURhdGFMb2dSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZBIbCgZiZWxpZW'
        'YYAiABKAlIAFIGYmVsaWVmiAEBEjIKEmFsdGVybmF0aXZlX2JlbGllZhgDIAEoCUgBUhFhbHRl'
        'cm5hdGl2ZUJlbGllZogBAUIJCgdfYmVsaWVmQhUKE19hbHRlcm5hdGl2ZV9iZWxpZWY=');

@$core.Deprecated('Use deletePositiveDataLogRequestDescriptor instead')
const DeletePositiveDataLogRequest$json = {
  '1': 'DeletePositiveDataLogRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeletePositiveDataLogRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletePositiveDataLogRequestDescriptor =
    $convert.base64Decode(
        'ChxEZWxldGVQb3NpdGl2ZURhdGFMb2dSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZA==');

@$core.Deprecated('Use addDataLogEvidenceRequestDescriptor instead')
const AddDataLogEvidenceRequest$json = {
  '1': 'AddDataLogEvidenceRequest',
  '2': [
    {'1': 'log_id', '3': 1, '4': 1, '5': 13, '10': 'logId'},
    {
      '1': 'evidence',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.record.DataLogEvidenceInput',
      '10': 'evidence'
    },
  ],
};

/// Descriptor for `AddDataLogEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addDataLogEvidenceRequestDescriptor =
    $convert.base64Decode(
        'ChlBZGREYXRhTG9nRXZpZGVuY2VSZXF1ZXN0EhUKBmxvZ19pZBgBIAEoDVIFbG9nSWQSOAoIZX'
        'ZpZGVuY2UYAiABKAsyHC5yZWNvcmQuRGF0YUxvZ0V2aWRlbmNlSW5wdXRSCGV2aWRlbmNl');

@$core.Deprecated('Use deleteDataLogEvidenceRequestDescriptor instead')
const DeleteDataLogEvidenceRequest$json = {
  '1': 'DeleteDataLogEvidenceRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteDataLogEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDataLogEvidenceRequestDescriptor =
    $convert.base64Decode(
        'ChxEZWxldGVEYXRhTG9nRXZpZGVuY2VSZXF1ZXN0Eg4KAmlkGAEgASgNUgJpZA==');

@$core.Deprecated('Use rateBeliefsRequestDescriptor instead')
const RateBeliefsRequest$json = {
  '1': 'RateBeliefsRequest',
  '2': [
    {'1': 'log_id', '3': 1, '4': 1, '5': 13, '10': 'logId'},
    {
      '1': 'belief_percent',
      '3': 2,
      '4': 1,
      '5': 5,
      '9': 0,
      '10': 'beliefPercent',
      '17': true
    },
    {
      '1': 'alternative_percent',
      '3': 3,
      '4': 1,
      '5': 5,
      '9': 1,
      '10': 'alternativePercent',
      '17': true
    },
  ],
  '8': [
    {'1': '_belief_percent'},
    {'1': '_alternative_percent'},
  ],
};

/// Descriptor for `RateBeliefsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rateBeliefsRequestDescriptor = $convert.base64Decode(
    'ChJSYXRlQmVsaWVmc1JlcXVlc3QSFQoGbG9nX2lkGAEgASgNUgVsb2dJZBIqCg5iZWxpZWZfcG'
    'VyY2VudBgCIAEoBUgAUg1iZWxpZWZQZXJjZW50iAEBEjQKE2FsdGVybmF0aXZlX3BlcmNlbnQY'
    'AyABKAVIAVISYWx0ZXJuYXRpdmVQZXJjZW50iAEBQhEKD19iZWxpZWZfcGVyY2VudEIWChRfYW'
    'x0ZXJuYXRpdmVfcGVyY2VudA==');

@$core.Deprecated('Use listBiasesRequestDescriptor instead')
const ListBiasesRequest$json = {
  '1': 'ListBiasesRequest',
};

/// Descriptor for `ListBiasesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBiasesRequestDescriptor =
    $convert.base64Decode('ChFMaXN0Qmlhc2VzUmVxdWVzdA==');

@$core.Deprecated('Use listBiasesResponseDescriptor instead')
const ListBiasesResponse$json = {
  '1': 'ListBiasesResponse',
  '2': [
    {
      '1': 'biases',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.record.CognitiveBias',
      '10': 'biases'
    },
  ],
};

/// Descriptor for `ListBiasesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBiasesResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0Qmlhc2VzUmVzcG9uc2USLQoGYmlhc2VzGAEgAygLMhUucmVjb3JkLkNvZ25pdGl2ZU'
    'JpYXNSBmJpYXNlcw==');

@$core.Deprecated('Use createBiasRequestDescriptor instead')
const CreateBiasRequest$json = {
  '1': 'CreateBiasRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateBiasRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBiasRequestDescriptor = $convert
    .base64Decode('ChFDcmVhdGVCaWFzUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1l');

@$core.Deprecated('Use renameBiasRequestDescriptor instead')
const RenameBiasRequest$json = {
  '1': 'RenameBiasRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `RenameBiasRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List renameBiasRequestDescriptor = $convert.base64Decode(
    'ChFSZW5hbWVCaWFzUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ'
    '==');

@$core.Deprecated('Use deleteBiasRequestDescriptor instead')
const DeleteBiasRequest$json = {
  '1': 'DeleteBiasRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
  ],
};

/// Descriptor for `DeleteBiasRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteBiasRequestDescriptor =
    $convert.base64Decode('ChFEZWxldGVCaWFzUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQ=');
