import 'package:flutter/foundation.dart';
import '../models/provider_content_model.dart';
import '../services/provider_service.dart';

enum ContentLoadState { idle, loading, success, empty, error }

/// ViewModel untuk menangani state dan data konten provider dari endpoint slug.
class ProviderContentViewModel extends ChangeNotifier {
  final String slug;
  String _title = '';
  List<ProviderContentItem> _items = [];
  ContentLoadState _state = ContentLoadState.idle;
  String _errorMessage = '';

  ProviderContentViewModel({required this.slug, String initialTitle = ''}) {
    _title = initialTitle;
  }

  String get title => _title;
  List<ProviderContentItem> get items => _items;
  ContentLoadState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> loadContent() async {
    _state = ContentLoadState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ProviderService.fetchProviderContent(slug);
      if (response.title.isNotEmpty) {
        _title = response.title;
      }
      _items = response.data;
      _state =
          _items.isEmpty ? ContentLoadState.empty : ContentLoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ContentLoadState.error;
    }

    notifyListeners();
  }
}

