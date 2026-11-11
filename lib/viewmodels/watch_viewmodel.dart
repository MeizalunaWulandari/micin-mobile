import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_colors.dart';
import '../models/watch_detail_model.dart';
import '../services/provider_service.dart';

enum WatchState { loading, success, error }

/// ViewModel untuk menangani fetching detail konten, inisialisasi pemutar video (DASH/HLS & DRM),
/// serta state Picture-in-Picture (PiP).
class WatchViewModel extends ChangeNotifier {
  final String providerSlug;
  final String contentId;
  String _title = '';

  WatchState _state = WatchState.loading;
  String _errorMessage = '';
  WatchDetailData? _detail;
  BetterPlayerController? _betterPlayerController;
  final GlobalKey _betterPlayerKey = GlobalKey();
  bool _isPipSupported = false;

  WatchViewModel({
    required this.providerSlug,
    required this.contentId,
    String initialTitle = '',
  }) {
    _title = initialTitle;
  }

  WatchState get state => _state;
  String get title => _title;
  String get errorMessage => _errorMessage;
  WatchDetailData? get detail => _detail;
  BetterPlayerController? get betterPlayerController => _betterPlayerController;
  GlobalKey get betterPlayerKey => _betterPlayerKey;
  bool get isPipSupported => _isPipSupported;

  Future<void> init() async {
    _state = WatchState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response =
          await ProviderService.fetchWatchDetail(providerSlug, contentId);
      if (response.title.isNotEmpty) {
        _title = response.title;
      }
      _detail = response.data;

      if (_detail == null) {
        throw Exception('Data konten tidak ditemukan');
      }

      if (_detail!.title.isNotEmpty) {
        _title = _detail!.title;
      }

      // Inisialisasi video player jika manifest tersedia
      if (_detail!.manifest.isNotEmpty) {
        _setupVideoPlayer(_detail!);
      }

      _state = WatchState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = WatchState.error;
    }

    notifyListeners();
  }

  void _setupVideoPlayer(WatchDetailData detail) {
    BetterPlayerVideoFormat? videoFormat;
    final manifestUrl = detail.manifest.toLowerCase();
    if (manifestUrl.contains('.mpd')) {
      videoFormat = BetterPlayerVideoFormat.dash;
    } else if (manifestUrl.contains('.m3u8')) {
      videoFormat = BetterPlayerVideoFormat.hls;
    } else {
      videoFormat = BetterPlayerVideoFormat.other;
    }

    BetterPlayerDrmConfiguration? drmConfig;
    if (detail.drm && detail.kid.isNotEmpty && detail.key.isNotEmpty) {
      String? clearKeyJson;
      try {
        clearKeyJson = BetterPlayerClearKeyUtils.generateKey(
          {detail.kid: detail.key},
        );
      } catch (_) {
        // Fallback jika format key bukan hex murni
        clearKeyJson = '{"${detail.kid}":"${detail.key}"}';
      }

      drmConfig = BetterPlayerDrmConfiguration(
        drmType: BetterPlayerDrmType.clearKey,
        clearKey: clearKeyJson,
      );
    }

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      detail.manifest,
      videoFormat: videoFormat,
      drmConfiguration: drmConfig,
      headers: AppConfig.defaultHeaders,
    );

    final configuration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      allowedScreenSleep: false,
      autoDispose: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        enableFullscreen: true,
        enableMute: true,
        enablePlayPause: true,
        enableProgressBar: true,
        controlBarColor: AppColors.surface.withValues(alpha: 0.85),
        progressBarPlayedColor: AppColors.primary,
        progressBarHandleColor: AppColors.primary,
        loadingColor: AppColors.primary,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      configuration,
      betterPlayerDataSource: dataSource,
    );

    // Cek dukungan Picture-in-Picture
    _checkPipSupport();
  }

  Future<void> _checkPipSupport() async {
    try {
      if (_betterPlayerController != null) {
        _isPipSupported =
            await _betterPlayerController!.isPictureInPictureSupported();
        notifyListeners();
      }
    } catch (_) {
      _isPipSupported = false;
    }
  }

  Future<void> enablePictureInPicture() async {
    try {
      if (_betterPlayerController != null) {
        await _betterPlayerController!.enablePictureInPicture(_betterPlayerKey);
      }
    } catch (e) {
      debugPrint('Error enabling PiP: $e');
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }
}

