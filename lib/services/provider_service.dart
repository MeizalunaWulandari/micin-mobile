import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../models/provider.dart';
import '../models/provider_content_model.dart';
import '../models/watch_detail_model.dart';

/// Response root dari endpoint `/provider`.
class ProviderResponse {
  final List<ProviderItem> data;
  final String message;
  final int status;

  const ProviderResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory ProviderResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return ProviderResponse(
      data: rawList
          .map((e) => ProviderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Service untuk mengambil data provider dan konten provider
class ProviderService {
  ProviderService._();

  static const String _endpoint = '/provider';

  /// Mengambil semua provider dari server `/provider`.
  /// Melempar [Exception] jika response bukan 200.
  static Future<List<ProviderItem>> fetchProviders() async {
    final uri = Uri.parse('${AppConfig.baseUrl}$_endpoint');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat provider (status: ${response.statusCode})');
    }
    final Map<String, dynamic> jsonBody =
        json.decode(response.body) as Map<String, dynamic>;
    return ProviderResponse.fromJson(jsonBody).data;
  }

  /// Mengambil konten dari provider berdasarkan slug: `BASE_URL/{slug}`.
  /// Melempar [Exception] jika response bukan 200.
  static Future<ProviderContentResponse> fetchProviderContent(String slug) async {
    final cleanSlug = slug.startsWith('/') ? slug.substring(1) : slug;
    final uri = Uri.parse('${AppConfig.baseUrl}/$cleanSlug');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception(
          'Gagal memuat konten ($cleanSlug): status ${response.statusCode}');
    }
    final Map<String, dynamic> jsonBody =
        json.decode(response.body) as Map<String, dynamic>;
    return ProviderContentResponse.fromJson(jsonBody);
  }

  /// Mengambil detail konten untuk halaman watch: `BASE_URL/{provider_slug}/{id}`.
  /// Melempar [Exception] jika response bukan 200.
  static Future<WatchDetailResponse> fetchWatchDetail(
      String providerSlug, String id) async {
    final cleanSlug =
        providerSlug.startsWith('/') ? providerSlug.substring(1) : providerSlug;
    final cleanId = id.startsWith('/') ? id.substring(1) : id;
    final uri = Uri.parse('${AppConfig.baseUrl}/$cleanSlug/$cleanId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception(
          'Gagal memuat detail konten ($cleanSlug/$cleanId): status ${response.statusCode}');
    }
    final Map<String, dynamic> jsonBody =
        json.decode(response.body) as Map<String, dynamic>;
    return WatchDetailResponse.fromJson(jsonBody);
  }
}
