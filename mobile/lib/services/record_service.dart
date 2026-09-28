import 'package:grpc/grpc.dart';

import '../proto/record.pbgrpc.dart';

/// Thrown when a call to the server fails, carrying a message fit to show the
/// user rather than a raw gRPC status.
class RecordException implements Exception {
  RecordException(this.message);

  final String message;

  @override
  String toString() => message;
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

  ClientChannel? _channel;
  RecordServiceClient? _client;

  /// Whether TLS should be used to reach the configured host.
  ///
  /// The decision is made on the host alone, matching the CLI: a loopback
  /// address is a local development server and is dialled in the clear;
  /// anything else is expected to present a certificate.
  bool requireSecureConnection() {
    if (host.isEmpty ||
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1') {
      return false;
    }
    return true;
  }

  ChannelCredentials _credentials() => requireSecureConnection()
      ? const ChannelCredentials.secure()
      : const ChannelCredentials.insecure();

  void _ensureInitialised() {
    if (_channel == null) {
      _channel = ClientChannel(
        host,
        port: port,
        options: ChannelOptions(credentials: _credentials()),
      );
      _client = RecordServiceClient(_channel!);
    }
  }

  Future<void> shutdown() async {
    await _channel?.shutdown();
    _channel = null;
    _client = null;
  }

  /// Runs a call, turning a gRPC failure into a [RecordException]. The server's
  /// status messages name the kind of problem and never quote the contents of
  /// a record, so they are safe to show as they are.
  Future<T> _call<T>(Future<T> Function(RecordServiceClient client) body) async {
    _ensureInitialised();
    try {
      return await body(_client!);
    } on GrpcError catch (error) {
      throw RecordException(error.message ?? error.codeName);
    } catch (error) {
      throw RecordException(error.toString());
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
