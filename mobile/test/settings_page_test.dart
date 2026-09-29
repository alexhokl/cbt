import 'package:cbt/widgets/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackendConfig.fromUrl', () {
    test('defaults an unparseable value to localhost:8080', () {
      final config = BackendConfig.fromUrl('');

      expect(config.host, 'localhost');
      expect(config.port, 8080);
    });

    test('resolves a bare https address to port 443', () {
      final config = BackendConfig.fromUrl('https://cbt.some-name.ts.net');

      expect(config.host, 'cbt.some-name.ts.net');
      expect(config.port, 443);
    });

    test('resolves a bare http address to port 8080', () {
      final config = BackendConfig.fromUrl('http://localhost');

      expect(config.host, 'localhost');
      expect(config.port, 8080);
    });

    test('resolves a schemeless address to port 8080, matching local dev',
        () {
      final config = BackendConfig.fromUrl('localhost');

      expect(config.host, 'localhost');
      expect(config.port, 8080);
    });

    test('an explicit port always wins over the scheme default', () {
      final https = BackendConfig.fromUrl('https://cbt.some-name.ts.net:8443');
      final http = BackendConfig.fromUrl('http://localhost:9090');

      expect(https.port, 8443);
      expect(http.port, 9090);
    });
  });
}
