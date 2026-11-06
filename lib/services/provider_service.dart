import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/provider.dart';

class ProviderService {
  static const String _baseUrl = 'https://example.com'; // replace with actual base URL
  static const String _endpoint = '/provider';

  /// Fetches providers from `$_baseUrl$_endpoint`.
  /// Returns a list of [ProviderItem] where `isPublish == true`.
  static Future<List<ProviderItem>> fetchProviders() async {
    final uri = Uri.parse('$_baseUrl$_endpoint');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load providers (status: ${response.statusCode})');
    }
    final Map<String, dynamic> jsonBody = json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = jsonBody['data'] as List<dynamic>;
    final providers = data.map((e) => ProviderItem.fromJson(e as Map<String, dynamic>)).toList();
    // Keep only published items
    return providers.where((p) => p.isPublish).toList();
  }
}
