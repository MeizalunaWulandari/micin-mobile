import 'dart:convert';
import 'dart:io';
import '../core/config/app_config.dart';
import '../models/app_update_model.dart';

/// Layanan untuk memeriksa pembaruan aplikasi ke server
class UpdateService {
  final HttpClient _client;

  UpdateService({HttpClient? client}) : _client = client ?? HttpClient();

  /// Mengambil informasi update aplikasi terbaru dari server
  Future<AppUpdateResponse?> checkUpdate() async {
    try {
      final uri = Uri.parse(AppConfig.checkUpdateUrl);
      final request = await _client.getUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        final jsonMap = jsonDecode(body) as Map<String, dynamic>;
        return AppUpdateResponse.fromJson(jsonMap);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

