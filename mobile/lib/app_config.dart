/// Build time constants, supplied with --dart-define.
class AppConfig {
  /// The commit the application was built from, so a bug report can be tied to
  /// a build. It is empty for a local debug build.
  static const String gitCommit = String.fromEnvironment('GIT_COMMIT');
}
