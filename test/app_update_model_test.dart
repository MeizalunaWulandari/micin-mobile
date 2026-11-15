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
      expect(
        AppConfig.userAgent,
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36',
      );
      expect(
        AppConfig.defaultHeaders['User-Agent'],
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36',
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

    test('Resolves dynamic {abi} and {version} in update_url template', () {
      const templateJson = '''
      {
        "data": {
          "latest_version_name": "1.0.0",
          "latest_build_number": 1,
          "is_force_update": false,
          "update_message": "Penambahan server UK dan optimalisasi streaming olahraga.",
          "update_url": "https://github.com/MicinProject-{abi}-{version}.apk"
        },
        "message": "GET_SUCCESS",
        "status": 200
      }
      ''';
      final jsonMap = jsonDecode(templateJson) as Map<String, dynamic>;
      final response = AppUpdateResponse.fromJson(jsonMap);
      final data = response.data!;

      expect(data.rawUpdateUrl, 'https://github.com/MicinProject-{abi}-{version}.apk');
      expect(data.updateUrl.contains('{abi}'), isFalse);
      expect(data.updateUrl.contains('{version}'), isFalse);
      expect(data.updateUrl.endsWith('-1.0.0.apk'), isTrue);
    });

    test('Resolves filename-only APK template to GitHub release link', () {
      const filenameJson = '''
      {
        "data": {
          "latest_version_name": "1.0.0",
          "latest_build_number": 1,
          "is_force_update": false,
          "update_message": "Update test",
          "update_url": "MicinProject_{abi}_{version}.apk"
        },
        "message": "GET_SUCCESS",
        "status": 200
      }
      ''';
      final jsonMap = jsonDecode(filenameJson) as Map<String, dynamic>;
      final response = AppUpdateResponse.fromJson(jsonMap);
      final data = response.data!;

      expect(
        data.updateUrl.startsWith('https://github.com/MeizalunaWulandari/micin-mobile/releases/download/v1.0.0/MicinProject_'),
        isTrue,
      );
      expect(data.updateUrl.endsWith('_1.0.0.apk'), isTrue);
    });
  });
}

