// This is a generated file - do not edit.
//
// Generated from proto/record.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'record.pb.dart' as $0;

export 'record.pb.dart';

/// RecordService is the gRPC API served by `cbt serve`. RPCs are added here and
/// registered in cmd/serve.go.
///
/// Both record types and the cognitive bias vocabulary live on a single service
/// rather than one service per entity: the client wrapper and the interceptor
/// wiring would otherwise be duplicated for no gain, and listing across both
/// record types needs a single endpoint anyway.
@$pb.GrpcServiceName('record.RecordService')
class RecordServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RecordServiceClient(super.channel, {super.options, super.interceptors});

  /// ListThoughtRecords returns the user's thought records, most recent event
  /// first. Filtering by challenged = false yields the day's work queue.
  $grpc.ResponseFuture<$0.ListThoughtRecordsResponse> listThoughtRecords(
    $0.ListThoughtRecordsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listThoughtRecords, request, options: options);
  }

  /// CreateThoughtRecord creates a record. Only the event is required: a record
  /// is routinely opened in the moment and completed later.
  $grpc.ResponseFuture<$0.ThoughtRecord> createThoughtRecord(
    $0.CreateThoughtRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createThoughtRecord, request, options: options);
  }

  /// GetThoughtRecord returns a single record by identifier.
  $grpc.ResponseFuture<$0.ThoughtRecord> getThoughtRecord(
    $0.GetThoughtRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getThoughtRecord, request, options: options);
  }

  /// UpdateThoughtRecord changes the free text columns of a record. Fields left
  /// unset keep their current value.
  $grpc.ResponseFuture<$0.ThoughtRecord> updateThoughtRecord(
    $0.UpdateThoughtRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateThoughtRecord, request, options: options);
  }

  /// ChallengeThoughtRecord records the second sitting: the alternative view,
  /// the re-rating of each feeling, and the biases identified in each thought.
  /// It stamps challenged_at so the record leaves the unchallenged queue.
  $grpc.ResponseFuture<$0.ThoughtRecord> challengeThoughtRecord(
    $0.ChallengeThoughtRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$challengeThoughtRecord, request,
        options: options);
  }

  /// DeleteThoughtRecord removes a record along with its thoughts and feelings.
  $grpc.ResponseFuture<$1.Empty> deleteThoughtRecord(
    $0.DeleteThoughtRecordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteThoughtRecord, request, options: options);
  }

  /// AddThought attaches a further negative thought to a record.
  $grpc.ResponseFuture<$0.ThoughtRecord> addThought(
    $0.AddThoughtRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addThought, request, options: options);
  }

  /// UpdateThought changes the wording of a thought and, optionally, the biases
  /// attached to it.
  $grpc.ResponseFuture<$0.ThoughtRecord> updateThought(
    $0.UpdateThoughtRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateThought, request, options: options);
  }

  /// SetHotThought marks a thought as the strongest of its record, clearing the
  /// flag from its siblings.
  $grpc.ResponseFuture<$0.ThoughtRecord> setHotThought(
    $0.SetHotThoughtRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setHotThought, request, options: options);
  }

  /// SetThoughtFactual records whether a thought was judged an accurate reading
  /// of the situation. Marking one factual while it carries a bias is rejected.
  $grpc.ResponseFuture<$0.ThoughtRecord> setThoughtFactual(
    $0.SetThoughtFactualRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setThoughtFactual, request, options: options);
  }

  /// DeleteThought removes a thought from its record.
  $grpc.ResponseFuture<$0.ThoughtRecord> deleteThought(
    $0.DeleteThoughtRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteThought, request, options: options);
  }

  /// AddFeeling attaches a rated feeling to a thought record.
  $grpc.ResponseFuture<$0.ThoughtRecord> addFeeling(
    $0.AddFeelingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addFeeling, request, options: options);
  }

  /// AddMapFeeling attaches a rated feeling to a map of worry.
  $grpc.ResponseFuture<$0.MapOfWorry> addMapFeeling(
    $0.AddMapFeelingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addMapFeeling, request, options: options);
  }

  /// DeleteFeeling removes a feeling from whichever record it belongs to.
  $grpc.ResponseFuture<$1.Empty> deleteFeeling(
    $0.DeleteFeelingRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteFeeling, request, options: options);
  }

  /// ListMapsOfWorry returns the user's maps of worry, most recent event first.
  $grpc.ResponseFuture<$0.ListMapsOfWorryResponse> listMapsOfWorry(
    $0.ListMapsOfWorryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMapsOfWorry, request, options: options);
  }

  /// CreateMapOfWorry creates a map. Setting derived_from_id marks it as an
  /// alternative reworking of an existing map, to be read alongside it.
  $grpc.ResponseFuture<$0.MapOfWorry> createMapOfWorry(
    $0.CreateMapOfWorryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createMapOfWorry, request, options: options);
  }

  /// GetMapOfWorry returns a single map together with the map it was derived
  /// from and any alternatives derived from it.
  $grpc.ResponseFuture<$0.GetMapOfWorryResponse> getMapOfWorry(
    $0.GetMapOfWorryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMapOfWorry, request, options: options);
  }

  /// UpdateMapOfWorry changes the free text columns of a map.
  $grpc.ResponseFuture<$0.MapOfWorry> updateMapOfWorry(
    $0.UpdateMapOfWorryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateMapOfWorry, request, options: options);
  }

  /// DeleteMapOfWorry removes a map along with its feelings. A map with
  /// alternatives derived from it is rejected.
  $grpc.ResponseFuture<$1.Empty> deleteMapOfWorry(
    $0.DeleteMapOfWorryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteMapOfWorry, request, options: options);
  }

  /// ListBiases returns the user's cognitive bias vocabulary, ordered by name.
  $grpc.ResponseFuture<$0.ListBiasesResponse> listBiases(
    $0.ListBiasesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listBiases, request, options: options);
  }

  /// CreateBias adds a user defined bias alongside the seeded ones.
  $grpc.ResponseFuture<$0.CognitiveBias> createBias(
    $0.CreateBiasRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createBias, request, options: options);
  }

  /// RenameBias renames a user defined bias. Builtin biases are rejected.
  $grpc.ResponseFuture<$0.CognitiveBias> renameBias(
    $0.RenameBiasRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$renameBias, request, options: options);
  }

  /// DeleteBias removes a user defined bias that is no longer in use.
  $grpc.ResponseFuture<$1.Empty> deleteBias(
    $0.DeleteBiasRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteBias, request, options: options);
  }

  // method descriptors

  static final _$listThoughtRecords = $grpc.ClientMethod<
          $0.ListThoughtRecordsRequest, $0.ListThoughtRecordsResponse>(
      '/record.RecordService/ListThoughtRecords',
      ($0.ListThoughtRecordsRequest value) => value.writeToBuffer(),
      $0.ListThoughtRecordsResponse.fromBuffer);
  static final _$createThoughtRecord =
      $grpc.ClientMethod<$0.CreateThoughtRecordRequest, $0.ThoughtRecord>(
          '/record.RecordService/CreateThoughtRecord',
          ($0.CreateThoughtRecordRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$getThoughtRecord =
      $grpc.ClientMethod<$0.GetThoughtRecordRequest, $0.ThoughtRecord>(
          '/record.RecordService/GetThoughtRecord',
          ($0.GetThoughtRecordRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$updateThoughtRecord =
      $grpc.ClientMethod<$0.UpdateThoughtRecordRequest, $0.ThoughtRecord>(
          '/record.RecordService/UpdateThoughtRecord',
          ($0.UpdateThoughtRecordRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$challengeThoughtRecord =
      $grpc.ClientMethod<$0.ChallengeThoughtRecordRequest, $0.ThoughtRecord>(
          '/record.RecordService/ChallengeThoughtRecord',
          ($0.ChallengeThoughtRecordRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$deleteThoughtRecord =
      $grpc.ClientMethod<$0.DeleteThoughtRecordRequest, $1.Empty>(
          '/record.RecordService/DeleteThoughtRecord',
          ($0.DeleteThoughtRecordRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$addThought =
      $grpc.ClientMethod<$0.AddThoughtRequest, $0.ThoughtRecord>(
          '/record.RecordService/AddThought',
          ($0.AddThoughtRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$updateThought =
      $grpc.ClientMethod<$0.UpdateThoughtRequest, $0.ThoughtRecord>(
          '/record.RecordService/UpdateThought',
          ($0.UpdateThoughtRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$setHotThought =
      $grpc.ClientMethod<$0.SetHotThoughtRequest, $0.ThoughtRecord>(
          '/record.RecordService/SetHotThought',
          ($0.SetHotThoughtRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$setThoughtFactual =
      $grpc.ClientMethod<$0.SetThoughtFactualRequest, $0.ThoughtRecord>(
          '/record.RecordService/SetThoughtFactual',
          ($0.SetThoughtFactualRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$deleteThought =
      $grpc.ClientMethod<$0.DeleteThoughtRequest, $0.ThoughtRecord>(
          '/record.RecordService/DeleteThought',
          ($0.DeleteThoughtRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$addFeeling =
      $grpc.ClientMethod<$0.AddFeelingRequest, $0.ThoughtRecord>(
          '/record.RecordService/AddFeeling',
          ($0.AddFeelingRequest value) => value.writeToBuffer(),
          $0.ThoughtRecord.fromBuffer);
  static final _$addMapFeeling =
      $grpc.ClientMethod<$0.AddMapFeelingRequest, $0.MapOfWorry>(
          '/record.RecordService/AddMapFeeling',
          ($0.AddMapFeelingRequest value) => value.writeToBuffer(),
          $0.MapOfWorry.fromBuffer);
  static final _$deleteFeeling =
      $grpc.ClientMethod<$0.DeleteFeelingRequest, $1.Empty>(
          '/record.RecordService/DeleteFeeling',
          ($0.DeleteFeelingRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listMapsOfWorry =
      $grpc.ClientMethod<$0.ListMapsOfWorryRequest, $0.ListMapsOfWorryResponse>(
          '/record.RecordService/ListMapsOfWorry',
          ($0.ListMapsOfWorryRequest value) => value.writeToBuffer(),
          $0.ListMapsOfWorryResponse.fromBuffer);
  static final _$createMapOfWorry =
      $grpc.ClientMethod<$0.CreateMapOfWorryRequest, $0.MapOfWorry>(
          '/record.RecordService/CreateMapOfWorry',
          ($0.CreateMapOfWorryRequest value) => value.writeToBuffer(),
          $0.MapOfWorry.fromBuffer);
  static final _$getMapOfWorry =
      $grpc.ClientMethod<$0.GetMapOfWorryRequest, $0.GetMapOfWorryResponse>(
          '/record.RecordService/GetMapOfWorry',
          ($0.GetMapOfWorryRequest value) => value.writeToBuffer(),
          $0.GetMapOfWorryResponse.fromBuffer);
  static final _$updateMapOfWorry =
      $grpc.ClientMethod<$0.UpdateMapOfWorryRequest, $0.MapOfWorry>(
          '/record.RecordService/UpdateMapOfWorry',
          ($0.UpdateMapOfWorryRequest value) => value.writeToBuffer(),
          $0.MapOfWorry.fromBuffer);
  static final _$deleteMapOfWorry =
      $grpc.ClientMethod<$0.DeleteMapOfWorryRequest, $1.Empty>(
          '/record.RecordService/DeleteMapOfWorry',
          ($0.DeleteMapOfWorryRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$listBiases =
      $grpc.ClientMethod<$0.ListBiasesRequest, $0.ListBiasesResponse>(
          '/record.RecordService/ListBiases',
          ($0.ListBiasesRequest value) => value.writeToBuffer(),
          $0.ListBiasesResponse.fromBuffer);
  static final _$createBias =
      $grpc.ClientMethod<$0.CreateBiasRequest, $0.CognitiveBias>(
          '/record.RecordService/CreateBias',
          ($0.CreateBiasRequest value) => value.writeToBuffer(),
          $0.CognitiveBias.fromBuffer);
  static final _$renameBias =
      $grpc.ClientMethod<$0.RenameBiasRequest, $0.CognitiveBias>(
          '/record.RecordService/RenameBias',
          ($0.RenameBiasRequest value) => value.writeToBuffer(),
          $0.CognitiveBias.fromBuffer);
  static final _$deleteBias =
      $grpc.ClientMethod<$0.DeleteBiasRequest, $1.Empty>(
          '/record.RecordService/DeleteBias',
          ($0.DeleteBiasRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('record.RecordService')
abstract class RecordServiceBase extends $grpc.Service {
  $core.String get $name => 'record.RecordService';

  RecordServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListThoughtRecordsRequest,
            $0.ListThoughtRecordsResponse>(
        'ListThoughtRecords',
        listThoughtRecords_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListThoughtRecordsRequest.fromBuffer(value),
        ($0.ListThoughtRecordsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.CreateThoughtRecordRequest, $0.ThoughtRecord>(
            'CreateThoughtRecord',
            createThoughtRecord_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateThoughtRecordRequest.fromBuffer(value),
            ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetThoughtRecordRequest, $0.ThoughtRecord>(
            'GetThoughtRecord',
            getThoughtRecord_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetThoughtRecordRequest.fromBuffer(value),
            ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateThoughtRecordRequest, $0.ThoughtRecord>(
            'UpdateThoughtRecord',
            updateThoughtRecord_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateThoughtRecordRequest.fromBuffer(value),
            ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ChallengeThoughtRecordRequest, $0.ThoughtRecord>(
            'ChallengeThoughtRecord',
            challengeThoughtRecord_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ChallengeThoughtRecordRequest.fromBuffer(value),
            ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteThoughtRecordRequest, $1.Empty>(
        'DeleteThoughtRecord',
        deleteThoughtRecord_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteThoughtRecordRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddThoughtRequest, $0.ThoughtRecord>(
        'AddThought',
        addThought_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddThoughtRequest.fromBuffer(value),
        ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateThoughtRequest, $0.ThoughtRecord>(
        'UpdateThought',
        updateThought_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateThoughtRequest.fromBuffer(value),
        ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetHotThoughtRequest, $0.ThoughtRecord>(
        'SetHotThought',
        setHotThought_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetHotThoughtRequest.fromBuffer(value),
        ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetThoughtFactualRequest, $0.ThoughtRecord>(
            'SetThoughtFactual',
            setThoughtFactual_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetThoughtFactualRequest.fromBuffer(value),
            ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteThoughtRequest, $0.ThoughtRecord>(
        'DeleteThought',
        deleteThought_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteThoughtRequest.fromBuffer(value),
        ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddFeelingRequest, $0.ThoughtRecord>(
        'AddFeeling',
        addFeeling_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddFeelingRequest.fromBuffer(value),
        ($0.ThoughtRecord value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddMapFeelingRequest, $0.MapOfWorry>(
        'AddMapFeeling',
        addMapFeeling_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AddMapFeelingRequest.fromBuffer(value),
        ($0.MapOfWorry value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteFeelingRequest, $1.Empty>(
        'DeleteFeeling',
        deleteFeeling_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteFeelingRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListMapsOfWorryRequest,
            $0.ListMapsOfWorryResponse>(
        'ListMapsOfWorry',
        listMapsOfWorry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListMapsOfWorryRequest.fromBuffer(value),
        ($0.ListMapsOfWorryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateMapOfWorryRequest, $0.MapOfWorry>(
        'CreateMapOfWorry',
        createMapOfWorry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateMapOfWorryRequest.fromBuffer(value),
        ($0.MapOfWorry value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetMapOfWorryRequest, $0.GetMapOfWorryResponse>(
            'GetMapOfWorry',
            getMapOfWorry_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetMapOfWorryRequest.fromBuffer(value),
            ($0.GetMapOfWorryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateMapOfWorryRequest, $0.MapOfWorry>(
        'UpdateMapOfWorry',
        updateMapOfWorry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateMapOfWorryRequest.fromBuffer(value),
        ($0.MapOfWorry value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteMapOfWorryRequest, $1.Empty>(
        'DeleteMapOfWorry',
        deleteMapOfWorry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteMapOfWorryRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListBiasesRequest, $0.ListBiasesResponse>(
        'ListBiases',
        listBiases_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListBiasesRequest.fromBuffer(value),
        ($0.ListBiasesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateBiasRequest, $0.CognitiveBias>(
        'CreateBias',
        createBias_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateBiasRequest.fromBuffer(value),
        ($0.CognitiveBias value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RenameBiasRequest, $0.CognitiveBias>(
        'RenameBias',
        renameBias_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RenameBiasRequest.fromBuffer(value),
        ($0.CognitiveBias value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteBiasRequest, $1.Empty>(
        'DeleteBias',
        deleteBias_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteBiasRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListThoughtRecordsResponse> listThoughtRecords_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListThoughtRecordsRequest> $request) async {
    return listThoughtRecords($call, await $request);
  }

  $async.Future<$0.ListThoughtRecordsResponse> listThoughtRecords(
      $grpc.ServiceCall call, $0.ListThoughtRecordsRequest request);

  $async.Future<$0.ThoughtRecord> createThoughtRecord_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateThoughtRecordRequest> $request) async {
    return createThoughtRecord($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> createThoughtRecord(
      $grpc.ServiceCall call, $0.CreateThoughtRecordRequest request);

  $async.Future<$0.ThoughtRecord> getThoughtRecord_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetThoughtRecordRequest> $request) async {
    return getThoughtRecord($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> getThoughtRecord(
      $grpc.ServiceCall call, $0.GetThoughtRecordRequest request);

  $async.Future<$0.ThoughtRecord> updateThoughtRecord_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateThoughtRecordRequest> $request) async {
    return updateThoughtRecord($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> updateThoughtRecord(
      $grpc.ServiceCall call, $0.UpdateThoughtRecordRequest request);

  $async.Future<$0.ThoughtRecord> challengeThoughtRecord_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ChallengeThoughtRecordRequest> $request) async {
    return challengeThoughtRecord($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> challengeThoughtRecord(
      $grpc.ServiceCall call, $0.ChallengeThoughtRecordRequest request);

  $async.Future<$1.Empty> deleteThoughtRecord_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteThoughtRecordRequest> $request) async {
    return deleteThoughtRecord($call, await $request);
  }

  $async.Future<$1.Empty> deleteThoughtRecord(
      $grpc.ServiceCall call, $0.DeleteThoughtRecordRequest request);

  $async.Future<$0.ThoughtRecord> addThought_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddThoughtRequest> $request) async {
    return addThought($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> addThought(
      $grpc.ServiceCall call, $0.AddThoughtRequest request);

  $async.Future<$0.ThoughtRecord> updateThought_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateThoughtRequest> $request) async {
    return updateThought($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> updateThought(
      $grpc.ServiceCall call, $0.UpdateThoughtRequest request);

  $async.Future<$0.ThoughtRecord> setHotThought_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetHotThoughtRequest> $request) async {
    return setHotThought($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> setHotThought(
      $grpc.ServiceCall call, $0.SetHotThoughtRequest request);

  $async.Future<$0.ThoughtRecord> setThoughtFactual_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetThoughtFactualRequest> $request) async {
    return setThoughtFactual($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> setThoughtFactual(
      $grpc.ServiceCall call, $0.SetThoughtFactualRequest request);

  $async.Future<$0.ThoughtRecord> deleteThought_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteThoughtRequest> $request) async {
    return deleteThought($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> deleteThought(
      $grpc.ServiceCall call, $0.DeleteThoughtRequest request);

  $async.Future<$0.ThoughtRecord> addFeeling_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddFeelingRequest> $request) async {
    return addFeeling($call, await $request);
  }

  $async.Future<$0.ThoughtRecord> addFeeling(
      $grpc.ServiceCall call, $0.AddFeelingRequest request);

  $async.Future<$0.MapOfWorry> addMapFeeling_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddMapFeelingRequest> $request) async {
    return addMapFeeling($call, await $request);
  }

  $async.Future<$0.MapOfWorry> addMapFeeling(
      $grpc.ServiceCall call, $0.AddMapFeelingRequest request);

  $async.Future<$1.Empty> deleteFeeling_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteFeelingRequest> $request) async {
    return deleteFeeling($call, await $request);
  }

  $async.Future<$1.Empty> deleteFeeling(
      $grpc.ServiceCall call, $0.DeleteFeelingRequest request);

  $async.Future<$0.ListMapsOfWorryResponse> listMapsOfWorry_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListMapsOfWorryRequest> $request) async {
    return listMapsOfWorry($call, await $request);
  }

  $async.Future<$0.ListMapsOfWorryResponse> listMapsOfWorry(
      $grpc.ServiceCall call, $0.ListMapsOfWorryRequest request);

  $async.Future<$0.MapOfWorry> createMapOfWorry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateMapOfWorryRequest> $request) async {
    return createMapOfWorry($call, await $request);
  }

  $async.Future<$0.MapOfWorry> createMapOfWorry(
      $grpc.ServiceCall call, $0.CreateMapOfWorryRequest request);

  $async.Future<$0.GetMapOfWorryResponse> getMapOfWorry_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetMapOfWorryRequest> $request) async {
    return getMapOfWorry($call, await $request);
  }

  $async.Future<$0.GetMapOfWorryResponse> getMapOfWorry(
      $grpc.ServiceCall call, $0.GetMapOfWorryRequest request);

  $async.Future<$0.MapOfWorry> updateMapOfWorry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateMapOfWorryRequest> $request) async {
    return updateMapOfWorry($call, await $request);
  }

  $async.Future<$0.MapOfWorry> updateMapOfWorry(
      $grpc.ServiceCall call, $0.UpdateMapOfWorryRequest request);

  $async.Future<$1.Empty> deleteMapOfWorry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteMapOfWorryRequest> $request) async {
    return deleteMapOfWorry($call, await $request);
  }

  $async.Future<$1.Empty> deleteMapOfWorry(
      $grpc.ServiceCall call, $0.DeleteMapOfWorryRequest request);

  $async.Future<$0.ListBiasesResponse> listBiases_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListBiasesRequest> $request) async {
    return listBiases($call, await $request);
  }

  $async.Future<$0.ListBiasesResponse> listBiases(
      $grpc.ServiceCall call, $0.ListBiasesRequest request);

  $async.Future<$0.CognitiveBias> createBias_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateBiasRequest> $request) async {
    return createBias($call, await $request);
  }

  $async.Future<$0.CognitiveBias> createBias(
      $grpc.ServiceCall call, $0.CreateBiasRequest request);

  $async.Future<$0.CognitiveBias> renameBias_Pre($grpc.ServiceCall $call,
      $async.Future<$0.RenameBiasRequest> $request) async {
    return renameBias($call, await $request);
  }

  $async.Future<$0.CognitiveBias> renameBias(
      $grpc.ServiceCall call, $0.RenameBiasRequest request);

  $async.Future<$1.Empty> deleteBias_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteBiasRequest> $request) async {
    return deleteBias($call, await $request);
  }

  $async.Future<$1.Empty> deleteBias(
      $grpc.ServiceCall call, $0.DeleteBiasRequest request);
}
