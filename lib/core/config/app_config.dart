/// Konfigurasi global aplikasi dan endpoint API
class AppConfig {
  AppConfig._();

  /// Base URL API Server
  static const String baseUrl = 'https://given-cary-zaxkyu-052e8853.koyeb.app';

  /// Endpoint untuk pemeriksaan update aplikasi
  static const String checkUpdateEndpoint = 'check-update';

  /// URL lengkap untuk check update
  static String get checkUpdateUrl => '$baseUrl/$checkUpdateEndpoint';

  /// Default User-Agent untuk seluruh HTTP & Streaming request
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36';

  /// Header default berisi User-Agent
  static Map<String, String> get defaultHeaders => {
        'User-Agent': userAgent,
      };
}

