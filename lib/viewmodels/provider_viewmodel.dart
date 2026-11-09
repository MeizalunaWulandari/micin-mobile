import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_update_model.dart';
import '../models/provider.dart';
import '../services/update_service.dart';
import '../services/provider_service.dart';

enum ProviderLoadState { idle, loading, success, empty, error }

/// ViewModel untuk Home Screen — mengelola:
/// 1. Pemeriksaan update otomatis saat startup.
/// 2. Version comparison untuk footer Home.
/// 3. Pengambilan & filtering daftar provider.
/// 4. Version-guard saat provider card diklik.
class ProviderViewModel extends ChangeNotifier {
  // ── Update Check ─────────────────────────────────────────────────────────
  bool _checkingUpdate = true;
  AppUpdateData? _updateData;
  int _currentBuildNumber = 0;
  String _currentVersionName = '1.0.0';

  bool get checkingUpdate => _checkingUpdate;
  bool get hasForceUpdate => _updateData?.isForceUpdate == true;
  AppUpdateData? get updateData => _updateData;
  int get currentBuildNumber => _currentBuildNumber;
  String get currentVersionName => _currentVersionName;

  /// Mengecek apakah versi aplikasi saat ini lebih rendah dari versi di server.
  bool get isUpdateAvailable {
    if (_updateData == null) return false;
    if (_updateData!.latestBuildNumber > 0 && _currentBuildNumber > 0) {
      return _currentBuildNumber < _updateData!.latestBuildNumber;
    }
    if (_updateData!.latestVersionName.isNotEmpty &&
        _currentVersionName.isNotEmpty) {
      return _currentVersionName != _updateData!.latestVersionName;
    }
    return false;
  }

  // ── Providers ─────────────────────────────────────────────────────────────
  ProviderLoadState _providerState = ProviderLoadState.idle;
  List<ProviderItem> _providers = [];
  String _errorMessage = '';

  ProviderLoadState get providerState => _providerState;
  List<ProviderItem> get providers => _providers;
  String get errorMessage => _errorMessage;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    // Baca versi dan build number aplikasi saat ini
    try {
      final info = await PackageInfo.fromPlatform();
      _currentBuildNumber = int.tryParse(info.buildNumber) ?? 1;
      _currentVersionName =
          info.version.isNotEmpty ? info.version : '1.0.0';
    } catch (_) {
      _currentBuildNumber = 1;
      _currentVersionName = '1.0.0';
    }

    // 1. Periksa update
    final updateResponse = await UpdateService.checkUpdate();
    _updateData = updateResponse?.data;
    _checkingUpdate = false;
    notifyListeners();

    // Jika force update, berhenti di sini — UI akan tampilkan modal.
    if (hasForceUpdate) return;

    // 2. Muat provider
    await loadProviders();
  }

  Future<void> loadProviders() async {
    _providerState = ProviderLoadState.loading;
    notifyListeners();

    try {
      final all = await ProviderService.fetchProviders();
      // Filter: hanya yang is_publish == true
      _providers = all.where((p) => p.isPublish).toList();
      _providerState =
          _providers.isEmpty ? ProviderLoadState.empty : ProviderLoadState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _providerState = ProviderLoadState.error;
    }

    notifyListeners();
  }

  /// Mengembalikan `true` jika build aplikasi cukup untuk mengakses [provider].
  bool canAccessProvider(ProviderItem provider) {
    return _currentBuildNumber >= provider.minRequiredBuild;
  }
}
