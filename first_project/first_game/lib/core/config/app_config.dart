/// App-wide configuration.
///
/// When you're ready to connect a real backend, add your base URL and
/// timeout settings here and set [useMockBackend] to false.
class AppConfig {
  /// Toggle this to switch between Mock and Real backend.
  /// Set to `false` once your API server is up.
  static const bool useMockBackend = false;

  static const String baseUrl = 'http://10.65.52.225:5000';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Storage keys
  static const String tokenKey = 'auth_token';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
}
