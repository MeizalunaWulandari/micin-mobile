import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../models/app_update_model.dart';

/// Service untuk memeriksa pembaruan aplikasi dari server.
class UpdateService {
  UpdateService._();

  /// Memanggil endpoint [AppConfig.checkUpdateUrl] dan mengembalikan
  /// [AppUpdateResponse]. Mengembalikan `null` jika terjadi error jaringan.
  static Future<AppUpdateResponse?> checkUpdate() async {
    final uri = Uri.parse(AppConfig.checkUpdateUrl);
    try {
      final response = await http
          .get(uri, headers: AppConfig.defaultHeaders)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final Map<String, dynamic> jsonBody =
          json.decode(response.body) as Map<String, dynamic>;
      return AppUpdateResponse.fromJson(jsonBody);
    } catch (_) {
      return null;
    }
  }
}
