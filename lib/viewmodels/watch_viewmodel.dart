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
  bool _isDisposed = false;
  String? _playerErrorMessage;
  bool _isStream403 = false;

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
  String? get playerErrorMessage => _playerErrorMessage;
  bool get isStream403 => _isStream403;

  Future<void> init() async {
    _state = WatchState.loading;
    _errorMessage = '';
    _playerErrorMessage = null;
    _isStream403 = false;
    notifyListeners();

    try {
      final response =
          await ProviderService.fetchWatchDetail(providerSlug, contentId);
      if (_isDisposed) return;

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
      if (_isDisposed) return;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = WatchState.error;
    }

    if (!_isDisposed) {
      notifyListeners();
    }
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
        headers: {
          'User-Agent': AppConfig.userAgent,
          'user-agent': AppConfig.userAgent,
        },
      );
    }

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      detail.manifest,
      videoFormat: videoFormat,
      drmConfiguration: drmConfig,
      headers: {
        'User-Agent': AppConfig.userAgent,
        'user-agent': AppConfig.userAgent,
        'Accept': '*/*',
      },
    );

    final configuration = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoDetectFullscreenAspectRatio: true,
      autoDetectFullscreenDeviceOrientation: true,
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
        enableRetry: false, // Ditangani sendiri via WatchViewModel/View agar tidak infinite loop
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

    // Daftarkan GlobalKey ke controller untuk keperluan PiP
    _betterPlayerController!.setBetterPlayerGlobalKey(_betterPlayerKey);

    // Tangani event pemutar video, khususnya deteksi error 403 atau error stream
    _betterPlayerController!.addEventsListener(_onPlayerEvent);

    // Cek dukungan Picture-in-Picture
    _checkPipSupport();
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (_isDisposed) return;

    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      final exceptionObj = event.parameters?['exception'];
      final exceptionStr = exceptionObj?.toString() ?? '';
      debugPrint('WatchViewModel: Player exception event received: $exceptionStr');

      final isForbidden = exceptionStr.contains('403') ||
          exceptionStr.toLowerCase().contains('forbidden') ||
          exceptionStr.toLowerCase().contains('response code: 403');

      _isStream403 = isForbidden;
      _playerErrorMessage = isForbidden
          ? 'Akses streaming ditolak (403 Forbidden). Siaran mungkin telah berakhir atau akses dibatasi.'
          : 'Gagal memutar streaming: $exceptionStr';

      // Hentikan pemutaran secara aman untuk mencegah ANR / infinite buffering
      try {
        _betterPlayerController?.pause();
      } catch (_) {}

      notifyListeners();
    }
  }

  Future<void> _checkPipSupport() async {
    try {
      if (_betterPlayerController != null) {
        _isPipSupported =
            await _betterPlayerController!.isPictureInPictureSupported();
        if (!_isDisposed) {
          notifyListeners();
        }
      }
    } catch (_) {
      _isPipSupported = false;
    }
  }

  Future<void> enablePictureInPicture() async {
    if (_betterPlayerController == null || _isDisposed) return;
    try {
      // Pastikan GlobalKey terpasang dan widget aktif di view tree
      if (_betterPlayerKey.currentContext == null) {
        debugPrint('Cannot enter PiP: betterPlayerKey context is null');
        return;
      }
      _betterPlayerController!.setBetterPlayerGlobalKey(_betterPlayerKey);
      await _betterPlayerController!.enablePictureInPicture(_betterPlayerKey);
    } catch (e) {
      debugPrint('Error enabling PiP: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    try {
      _betterPlayerController?.removeEventsListener(_onPlayerEvent);
      _betterPlayerController?.dispose();
    } catch (e) {
      debugPrint('Error disposing BetterPlayerController: $e');
    }
    _betterPlayerController = null;
    super.dispose();
  }
}

