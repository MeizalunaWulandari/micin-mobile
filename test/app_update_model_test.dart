import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/models/app_update_model.dart';

void main() {
  group('AppConfig Tests', () {
    test('Config values match requirements', () {
      expect(AppConfig.baseUrl, 'https://given-cary-zaxkyu-052e8853.koyeb.app');
      expect(AppConfig.checkUpdateEndpoint, 'check-update');
      expect(
        AppConfig.checkUpdateUrl,
        'https://given-cary-zaxkyu-052e8853.koyeb.app/check-update',
      );
    });
  });

  group('AppUpdateModel JSON Serialization Tests', () {
    const rawJson = '''
    {
      "data": {
        "latest_version_name": "1.0.1",
        "latest_build_number": 1,
        "is_force_update": false,
        "update_message": "Penambahan server UK dan optimalisasi streaming olahraga.",
        "update_url": "https://domain-kamu.com/micin-v1.0.1.apk"
      },
      "message": "GET_SUCCESS",
      "status": 200
    }
    ''';

    test('Parses check-update JSON contract correctly', () {
      final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final response = AppUpdateResponse.fromJson(jsonMap);

      expect(response.status, 200);
      expect(response.message, 'GET_SUCCESS');
      expect(response.isSuccess, isTrue);

      final data = response.data;
      expect(data, isNotNull);
      expect(data!.latestVersionName, '1.0.1');
      expect(data.latestBuildNumber, 1);
      expect(data.isForceUpdate, isFalse);
      expect(
        data.updateMessage,
        'Penambahan server UK dan optimalisasi streaming olahraga.',
      );
      expect(data.updateUrl, 'https://domain-kamu.com/micin-v1.0.1.apk');
    });

    test('Serializes back to JSON correctly', () {
      final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final response = AppUpdateResponse.fromJson(jsonMap);
      final serialized = response.toJson();

      expect(serialized['status'], 200);
      expect(serialized['message'], 'GET_SUCCESS');
      expect(serialized['data']['latest_version_name'], '1.0.1');
      expect(serialized['data']['is_force_update'], false);
    });
  });
}

