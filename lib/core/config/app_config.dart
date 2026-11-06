/// Konfigurasi global aplikasi dan endpoint API
class AppConfig {
  AppConfig._();

  /// Base URL API Server
  static const String baseUrl = 'https://given-cary-zaxkyu-052e8853.koyeb.app';

  /// Endpoint untuk pemeriksaan update aplikasi
  static const String checkUpdateEndpoint = 'check-update';

  /// URL lengkap untuk check update
  static String get checkUpdateUrl => '$baseUrl/$checkUpdateEndpoint';
}

