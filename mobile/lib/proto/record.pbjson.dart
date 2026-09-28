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
  ],
  '8': [
    {'1': '_parent_id'},
  ],
};

/// Descriptor for `NegativeThought`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List negativeThoughtDescriptor = $convert.base64Decode(
    'Cg9OZWdhdGl2ZVRob3VnaHQSDgoCaWQYASABKA1SAmlkEhIKBGJvZHkYAiABKAlSBGJvZHkSFQ'
    'oGaXNfaG90GAMgASgIUgVpc0hvdBItCgZiaWFzZXMYBCADKAsyFS5yZWNvcmQuQ29nbml0aXZl'
    'Qmlhc1IGYmlhc2VzEiAKCXBhcmVudF9pZBgFIAEoDUgAUghwYXJlbnRJZIgBARIdCgppc19mYW'
    'N0dWFsGAYgASgIUglpc0ZhY3R1YWxCDAoKX3BhcmVudF9pZA==');

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
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0Qg4KDF9vY2N1cnJlZF9hdE'
    'IQCg5fY2hhbGxlbmdlZF9hdA==');

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
  ],
};

/// Descriptor for `ThoughtInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List thoughtInputDescriptor = $convert.base64Decode(
    'CgxUaG91Z2h0SW5wdXQSEgoEYm9keRgBIAEoCVIEYm9keRIVCgZpc19ob3QYAiABKAhSBWlzSG'
    '90EhYKBmJpYXNlcxgDIAMoCVIGYmlhc2Vz');

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
    '5nSW5wdXRSCGZlZWxpbmdzQg4KDF9vY2N1cnJlZF9hdA==');

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
  ],
  '8': [
    {'1': '_event'},
    {'1': '_occurred_at'},
    {'1': '_alternative_view'},
    {'1': '_feelings_now'},
  ],
};

/// Descriptor for `UpdateThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateThoughtRecordRequestDescriptor = $convert.base64Decode(
    'ChpVcGRhdGVUaG91Z2h0UmVjb3JkUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSGQoFZXZlbnQYAi'
    'ABKAlIAFIFZXZlbnSIAQESQAoLb2NjdXJyZWRfYXQYAyABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'VGltZXN0YW1wSAFSCm9jY3VycmVkQXSIAQESKgoRY2xlYXJfb2NjdXJyZWRfYXQYBCABKAhSD2'
    'NsZWFyT2NjdXJyZWRBdBIuChBhbHRlcm5hdGl2ZV92aWV3GAUgASgJSAJSD2FsdGVybmF0aXZl'
    'Vmlld4gBARImCgxmZWVsaW5nc19ub3cYBiABKAlIA1ILZmVlbGluZ3NOb3eIAQFCCAoGX2V2ZW'
    '50Qg4KDF9vY2N1cnJlZF9hdEITChFfYWx0ZXJuYXRpdmVfdmlld0IPCg1fZmVlbGluZ3Nfbm93');

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
    {'1': 'is_factual', '3': 3, '4': 1, '5': 8, '10': 'isFactual'},
  ],
  '8': [
    {'1': '_biases'},
  ],
};

/// Descriptor for `ThoughtJudgement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List thoughtJudgementDescriptor = $convert.base64Decode(
    'ChBUaG91Z2h0SnVkZ2VtZW50Eh0KCnRob3VnaHRfaWQYASABKA1SCXRob3VnaHRJZBIuCgZiaW'
    'FzZXMYAiABKAsyES5yZWNvcmQuQmlhc05hbWVzSABSBmJpYXNlc4gBARIdCgppc19mYWN0dWFs'
    'GAMgASgIUglpc0ZhY3R1YWxCCQoHX2JpYXNlcw==');

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
  ],
};

/// Descriptor for `ChallengeThoughtRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List challengeThoughtRecordRequestDescriptor = $convert.base64Decode(
    'Ch1DaGFsbGVuZ2VUaG91Z2h0UmVjb3JkUmVxdWVzdBIOCgJpZBgBIAEoDVICaWQSKQoQYWx0ZX'
    'JuYXRpdmVfdmlldxgCIAEoCVIPYWx0ZXJuYXRpdmVWaWV3EiEKDGZlZWxpbmdzX25vdxgDIAEo'
    'CVILZmVlbGluZ3NOb3cSRAoRZmVlbGluZ19yZXJhdGluZ3MYBCADKAsyFy5yZWNvcmQuRmVlbG'
    'luZ1JlcmF0aW5nUhBmZWVsaW5nUmVyYXRpbmdzEjQKCHRob3VnaHRzGAUgAygLMhgucmVjb3Jk'
    'LlRob3VnaHRKdWRnZW1lbnRSCHRob3VnaHRz');

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
