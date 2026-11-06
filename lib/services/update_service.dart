import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateInfo {
  final bool isForceUpdate;
  final String? updateUrl;
  final String? message;

  UpdateInfo({required this.isForceUpdate, this.updateUrl, this.message});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        isForceUpdate: json['is_force_update'] as bool,
        updateUrl: json['update_url'] as String?,
        message: json['message'] as String?,
      );
}

class UpdateService {
  static const String _baseUrl = 'https://example.com'; // replace with real base URL
  static const String _endpoint = '/check-update';

  /// Checks for an app update.
  /// Returns null if no update info is available.
  static Future<UpdateInfo?> checkUpdate() async {
    final uri = Uri.parse('$_baseUrl$_endpoint');
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final Map<String, dynamic> jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return UpdateInfo.fromJson(jsonBody);
    } catch (_) {
      return null;
    }
  }
}
