import 'package:flutter_helper/grpc.dart';

import '../proto/record.pbgrpc.dart';

/// Thrown when a call to the server fails, carrying a message fit to show the
/// user rather than a raw gRPC status.
class RecordException extends ServiceException {
  RecordException(super.message, {super.grpcError});
}

/// RecordService wraps the gRPC client for the cbt server.
///
/// There is no application level credential anywhere in this class. The server
/// authenticates by network identity: it resolves the caller's tailnet address
/// to a user. Being on the tailnet is the credential, so there is no token to
/// store and nothing to attach to a call.
class RecordService {
  RecordService({this.host = _defaultHost, this.port = _defaultPort});

  static const String _defaultHost = 'localhost';
  static const int _defaultPort = 8080;

  final String host;
  final int port;

  late final GrpcChannelHolder _channel = GrpcChannelHolder(
    host: host,
    port: port,
  );
  RecordServiceClient? _client;

  /// Whether TLS should be used to reach the configured host.
  ///
  /// The decision is made on the host alone, matching the CLI: a loopback
  /// address is a local development server and is dialled in the clear;
  /// anything else is expected to present a certificate.
  bool requireSecureConnection() => _channel.useTls;

  Future<void> shutdown() async {
    _client = null;
    await _channel.shutdown();
  }

  /// Runs a call, turning a gRPC failure into a [RecordException]. The server's
  /// status messages name the kind of problem and never quote the contents of
  /// a record, so they are safe to show as they are.
  Future<T> _call<T>(Future<T> Function(RecordServiceClient client) body) async {
    final client = _client ??= RecordServiceClient(_channel.channel);
    try {
      return await body(client);
    } catch (error) {
      final exception = ServiceException.from(error);
      throw RecordException(exception.message, grpcError: exception.grpcError);
    }
  }

  Future<List<ThoughtRecord>> listThoughtRecords({
    bool? challenged,
    String search = '',
  }) {
    final request = ListThoughtRecordsRequest()..search = search;
    if (challenged != null) {
      request.challenged = challenged;
    }
    return _call(
      (client) async => (await client.listThoughtRecords(request)).records,
    );
  }

  Future<ThoughtRecord> getThoughtRecord(int id) => _call(
        (client) =>
            client.getThoughtRecord(GetThoughtRecordRequest()..id = id),
      );

  Future<ThoughtRecord> createThoughtRecord(
    CreateThoughtRecordRequest request,
  ) =>
      _call((client) => client.createThoughtRecord(request));

  Future<ThoughtRecord> updateThoughtRecord(
    UpdateThoughtRecordRequest request,
  ) =>
      _call((client) => client.updateThoughtRecord(request));

  Future<ThoughtRecord> challengeThoughtRecord(
    ChallengeThoughtRecordRequest request,
  ) =>
      _call((client) => client.challengeThoughtRecord(request));

  Future<void> deleteThoughtRecord(int id) => _call(
        (client) =>
            client.deleteThoughtRecord(DeleteThoughtRecordRequest()..id = id),
      );

  Future<ThoughtRecord> addThought(int recordId, ThoughtInput thought) => _call(
        (client) => client.addThought(
          AddThoughtRequest()
            ..recordId = recordId
            ..thought = thought,
        ),
      );

  Future<ThoughtRecord> deleteThought(int id) => _call(
        (client) => client.deleteThought(DeleteThoughtRequest()..id = id),
      );

  Future<ThoughtRecord> setHotThought(int id) => _call(
        (client) => client.setHotThought(SetHotThoughtRequest()..id = id),
      );

  Future<ThoughtRecord> setThoughtEvidence(int id, String evidence) => _call(
        (client) => client.setThoughtEvidence(
          SetThoughtEvidenceRequest()
            ..id = id
            ..evidence = evidence,
        ),
      );

  Future<ThoughtRecord> addFeeling(int recordId, FeelingInput feeling) => _call(
        (client) => client.addFeeling(
          AddFeelingRequest()
            ..recordId = recordId
            ..feeling = feeling,
        ),
      );

  Future<void> deleteFeeling(int id) => _call(
        (client) => client.deleteFeeling(DeleteFeelingRequest()..id = id),
      );

  Future<List<MapOfWorry>> listMapsOfWorry({String search = ''}) => _call(
        (client) async =>
            (await client.listMapsOfWorry(ListMapsOfWorryRequest()..search = search))
                .maps,
      );

  Future<GetMapOfWorryResponse> getMapOfWorry(int id) => _call(
        (client) => client.getMapOfWorry(GetMapOfWorryRequest()..id = id),
      );

  Future<MapOfWorry> createMapOfWorry(CreateMapOfWorryRequest request) =>
      _call((client) => client.createMapOfWorry(request));

  Future<MapOfWorry> updateMapOfWorry(UpdateMapOfWorryRequest request) =>
      _call((client) => client.updateMapOfWorry(request));

  Future<void> deleteMapOfWorry(int id) => _call(
        (client) => client.deleteMapOfWorry(DeleteMapOfWorryRequest()..id = id),
      );

  Future<List<BehaviouralExperiment>> listBehaviouralExperiments({
    bool? completed,
    String search = '',
  }) {
    final request = ListBehaviouralExperimentsRequest()..search = search;
    if (completed != null) {
      request.completed = completed;
    }
    return _call(
      (client) async =>
          (await client.listBehaviouralExperiments(request)).experiments,
    );
  }

  Future<BehaviouralExperiment> getBehaviouralExperiment(int id) => _call(
        (client) => client.getBehaviouralExperiment(
          GetBehaviouralExperimentRequest()..id = id,
        ),
      );

  Future<BehaviouralExperiment> createBehaviouralExperiment(
    CreateBehaviouralExperimentRequest request,
  ) =>
      _call((client) => client.createBehaviouralExperiment(request));

  Future<BehaviouralExperiment> updateBehaviouralExperiment(
    UpdateBehaviouralExperimentRequest request,
  ) =>
      _call((client) => client.updateBehaviouralExperiment(request));

  Future<BehaviouralExperiment> completeBehaviouralExperiment(
    CompleteBehaviouralExperimentRequest request,
  ) =>
      _call((client) => client.completeBehaviouralExperiment(request));

  Future<void> deleteBehaviouralExperiment(int id) => _call(
        (client) => client.deleteBehaviouralExperiment(
          DeleteBehaviouralExperimentRequest()..id = id,
        ),
      );

  Future<BehaviouralExperiment> addExperimentFeeling(
    int experimentId,
    FeelingInput feeling,
  ) =>
      _call(
        (client) => client.addExperimentFeeling(
          AddExperimentFeelingRequest()
            ..experimentId = experimentId
            ..feeling = feeling,
        ),
      );

  Future<List<CognitiveBias>> listBiases() => _call(
        (client) async =>
            (await client.listBiases(ListBiasesRequest())).biases,
      );

  Future<CognitiveBias> createBias(String name) => _call(
        (client) => client.createBias(CreateBiasRequest()..name = name),
      );

  Future<void> deleteBias(int id) => _call(
        (client) => client.deleteBias(DeleteBiasRequest()..id = id),
      );
}
