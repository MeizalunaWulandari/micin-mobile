import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/watch_detail_model.dart';

void main() {
  group('WatchDetailModel JSON Serialization Tests', () {
    const rawJson = '''
    {
      "data": {
        "id": "20261109047018",
        "title": "KB스타즈 vs 우리은행",
        "description": "KB스타즈 vs 우리은행",
        "schedule": "17:01 WIB",
        "status": "ended",
        "type": "past_event",
        "thumbnail": "https://sports-phinf.pstatic.net/20201019_179/1603086813757DIFb4_PNG/03_basketball.png",
        "manifest": "https://example.com/stream.mpd",
        "drm": true,
        "kid": "0123456789abcdef0123456789abcdef",
        "key": "fedcba9876543210fedcba9876543210"
      },
      "message": "GET_SUCCESS",
      "status": 200,
      "title": "Naver"
    }
    ''';

    test('Parses watch detail response correctly', () {
      final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final response = WatchDetailResponse.fromJson(jsonMap);

      expect(response.status, 200);
      expect(response.message, 'GET_SUCCESS');
      expect(response.title, 'Naver');
      expect(response.isSuccess, isTrue);

      final data = response.data;
      expect(data, isNotNull);
      expect(data!.id, '20261109047018');
      expect(data.title, 'KB스타즈 vs 우리은행');
      expect(data.schedule, '17:01 WIB');
      expect(data.status, 'ended');
      expect(data.type, 'past_event');
      expect(data.manifest, 'https://example.com/stream.mpd');
      expect(data.drm, isTrue);
      expect(data.kid, '0123456789abcdef0123456789abcdef');
      expect(data.key, 'fedcba9876543210fedcba9876543210');
    });

    test('Handles unencrypted stream (drm: false)', () {
      const rawJsonNoDrm = '''
      {
        "data": {
          "id": "20261109047018",
          "title": "Unencrypted Stream",
          "description": "",
          "schedule": "17:01 WIB",
          "status": "upcoming",
          "type": "upcoming_event",
          "thumbnail": "",
          "manifest": "https://example.com/stream.m3u8",
          "drm": false,
          "kid": "",
          "key": ""
        },
        "message": "GET_SUCCESS",
        "status": 200,
        "title": "Naver"
      }
      ''';
      final jsonMap = jsonDecode(rawJsonNoDrm) as Map<String, dynamic>;
      final response = WatchDetailResponse.fromJson(jsonMap);

      expect(response.isSuccess, isTrue);
      expect(response.data?.drm, isFalse);
      expect(response.data?.manifest, 'https://example.com/stream.m3u8');
    });

    test('Serializes back to JSON correctly', () {
      final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final response = WatchDetailResponse.fromJson(jsonMap);
      final serialized = response.toJson();

      expect(serialized['status'], 200);
      expect(serialized['message'], 'GET_SUCCESS');
      expect(serialized['title'], 'Naver');
      expect(serialized['data']['id'], '20261109047018');
      expect(serialized['data']['drm'], true);
    });
  });
}

