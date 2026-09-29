import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/record_service.dart';

/// BackendConfig is the parsed form of the server address setting.
class BackendConfig {
  const BackendConfig({required this.host, required this.port});

  final String host;
  final int port;

  /// Parses a stored address. A value that does not parse falls back to the
  /// default rather than throwing, so a half typed address cannot leave the
  /// app unable to start.
  ///
  /// When no port is given explicitly, the fallback is scheme aware rather
  /// than a single fixed number: the tsnet server terminates TLS on 443, so a
  /// bare `https://` address (the normal case, pointing at a tailnet host)
  /// has to resolve to 443, while a bare `http://` address (local
  /// development) keeps resolving to 8080, matching the server's own
  /// default port.
  factory BackendConfig.fromUrl(String url) {
    final uri = Uri.tryParse(url.contains('://') ? url : 'http://$url');
    if (uri == null || uri.host.isEmpty) {
      return const BackendConfig(host: 'localhost', port: 8080);
    }
    return BackendConfig(
      host: uri.host,
      port: uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 8080),
    );
  }

  static Future<BackendConfig> load() async {
    final prefs = SharedPreferencesAsync();
    final url = await prefs.getString(SettingsPage.backendUrlKey) ??
        SettingsPage.defaultBackendUrl;
    return BackendConfig.fromUrl(url);
  }

  /// Builds a service for the configured server. Every page calls this rather
  /// than holding a long lived client, so changing the address in settings
  /// takes effect on the next screen without a restart.
  static Future<RecordService> buildService() async {
    final config = await load();
    return RecordService(host: config.host, port: config.port);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String backendUrlKey = 'backend_url';
  static const String defaultBackendUrl = 'https://cbt.some-name.ts.net';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = SharedPreferencesAsync();
    final url = await prefs.getString(SettingsPage.backendUrlKey) ??
        SettingsPage.defaultBackendUrl;
    if (!mounted) {
      return;
    }
    _controller.text = url;
  }

  Future<void> _save(String value) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setString(SettingsPage.backendUrlKey, value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            onChanged: _save,
            decoration: InputDecoration(
              labelText: l10n.settingsBackendUrl,
              helperText: l10n.settingsBackendUrlHelp,
              helperMaxLines: 3,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          // The storage model is stated plainly rather than left for the user
          // to guess at, given what these records contain.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settingsPrivacy,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          if (AppConfig.gitCommit.isNotEmpty) ...[
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.settingsVersion),
              subtitle: Text(AppConfig.gitCommit),
            ),
          ],
        ],
      ),
    );
  }
}
