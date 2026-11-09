import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/provider_content_model.dart';

void main() {
  group('ProviderContentModel JSON Serialization Tests', () {
    const rawJson = '''
    {
      "data": [
        {
          "id": "20261109047018",
          "title": "KB스타즈 vs 우리은행",
          "description": "KB스타즈 vs 우리은행",
          "schedule": "17:01 WIB",
          "category": "WKBL",
          "status": "ended",
          "type": "past_event",
          "has_image": true,
          "thumbnail": "https://sports-phinf.pstatic.net/20201019_179/1603086813757DIFb4_PNG/03_basketball.png",
          "episode_count": 0
        },
        {
          "id": "20261110SC1",
          "title": "삼성 우승을 만든 '핵심 지표' | 스탯캐스터",
          "description": "삼성 우승을 만든 '핵심 지표' | 스탯캐스터",
          "schedule": "10 November 2026 | 12:00 WIB",
          "category": "국내야구기타",
          "status": "upcoming",
          "type": "upcoming_event",
          "has_image": false,
          "thumbnail": "",
          "episode_count": 0
        }
      ],
      "message": "NAVER_RESPONSE",
      "status": 200,
      "title": "Naver"
    }
    ''';

    test('Parses provider content response correctly', () {
      final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final response = ProviderContentResponse.fromJson(jsonMap);

      expect(response.status, 200);
      expect(response.message, 'NAVER_RESPONSE');
      expect(response.title, 'Naver');
      expect(response.isSuccess, isTrue);
      expect(response.data.length, 2);

      // Item 1 (has_image == true)
      final item1 = response.data[0];
      expect(item1.id, '20261109047018');
      expect(item1.title, 'KB스타즈 vs 우리은행');
      expect(item1.category, 'WKBL');
      expect(item1.status, 'ended');
      expect(item1.type, 'past_event');
      expect(item1.hasImage, isTrue);
      expect(item1.thumbnail, contains('03_basketball.png'));
      expect(item1.episodeCount, 0);

      // Item 2 (has_image == false)
      final item2 = response.data[1];
      expect(item2.id, '20261110SC1');
      expect(item2.hasImage, isFalse);
      expect(item2.status, 'upcoming');
    });

    test('Serializes provider content response back to JSON correctly', () {
      final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
      final response = ProviderContentResponse.fromJson(jsonMap);
      final serialized = response.toJson();

      expect(serialized['status'], 200);
      expect(serialized['message'], 'NAVER_RESPONSE');
      expect(serialized['title'], 'Naver');
      expect(serialized['data'], isA<List>());
      expect((serialized['data'] as List).length, 2);
    });
  });
}

