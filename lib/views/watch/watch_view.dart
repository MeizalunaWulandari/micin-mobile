import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../models/watch_detail_model.dart';
import '../../viewmodels/watch_viewmodel.dart';

/// Halaman Watch / Detail Konten Provider
/// Menampilkan:
/// - Pemutar video streaming (DASH/HLS & DRM ClearKey)
/// - Fitur Picture-in-Picture (PiP)
/// - Informasi detail siaran
/// - Tab Chat Admin bertuliskan "Chat Under Development"
class WatchView extends StatefulWidget {
  final String providerSlug;
  final String contentId;
  final String initialTitle;

  const WatchView({
    super.key,
    required this.providerSlug,
    required this.contentId,
    this.initialTitle = '',
  });

  @override
  State<WatchView> createState() => _WatchViewState();
}

class _WatchViewState extends State<WatchView>
    with SingleTickerProviderStateMixin {
  late final WatchViewModel _vm;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _vm = WatchViewModel(
      providerSlug: widget.providerSlug,
      contentId: widget.contentId,
      initialTitle: widget.initialTitle,
    );
    _vm.addListener(_onViewModelChanged);
    _vm.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vm.removeListener(_onViewModelChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _vm.title.isNotEmpty ? _vm.title : 'Watch',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_vm.state == WatchState.success &&
              _vm.betterPlayerController != null)
            IconButton(
              icon: const Icon(Icons.picture_in_picture_alt_rounded),
              tooltip: 'Picture in Picture',
              onPressed: _vm.enablePictureInPicture,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_vm.state) {
      case WatchState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Memuat siaran...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );

      case WatchState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gagal memuat tayangan.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _vm.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                  ),
                  onPressed: _vm.init,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );

      case WatchState.success:
        final detail = _vm.detail!;
        return Column(
          children: [
            // 1. Video Player Area (16:9)
            _buildVideoPlayerSection(detail),

            // 2. Navigation Tabs (Info & Chat)
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline_rounded), text: 'Info'),
                  Tab(icon: Icon(Icons.chat_bubble_outline_rounded), text: 'Chat'),
                ],
              ),
            ),

            // 3. Tab Content Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(detail),
                  _buildChatTab(),
                ],
              ),
            ),
          ],
        );
    }
  }

  // ── Video Player Area ───────────────────────────────────────────────────────
  Widget _buildVideoPlayerSection(WatchDetailData detail) {
    if (detail.manifest.isNotEmpty && _vm.betterPlayerController != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(
          key: _vm.betterPlayerKey,
          controller: _vm.betterPlayerController!,
        ),
      );
    }

    // Tampilan alternatif jika manifest kosong atau tidak tersedia
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppColors.surface,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (detail.thumbnail.isNotEmpty)
              Image.network(
                detail.thumbnail,
                headers: AppConfig.defaultHeaders,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_disabled_rounded,
                      color: AppColors.textSecondary,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Stream belum tersedia',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Tab ───────────────────────────────────────────────────────────────
  Widget _buildInfoTab(WatchDetailData detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            detail.title.isNotEmpty ? detail.title : 'Detail Siaran',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Badges: Status & DRM
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildBadge(
                detail.status.toUpperCase(),
                detail.status.toLowerCase() == 'upcoming'
                    ? AppColors.secondary
                    : (detail.status.toLowerCase() == 'ended'
                        ? AppColors.textSecondary
                        : AppColors.primary),
              ),
              if (detail.drm)
                _buildBadge('DRM PROTECTED', AppColors.primary),
              if (detail.type.isNotEmpty)
                _buildBadge(detail.type, AppColors.surfaceVariant),
            ],
          ),
          const SizedBox(height: 14),

          // Schedule
          if (detail.schedule.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  detail.schedule,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          const Divider(color: AppColors.border),
          const SizedBox(height: 10),

          // Description
          if (detail.description.isNotEmpty) ...[
            const Text(
              'Deskripsi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action Button: PiP trigger
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _vm.enablePictureInPicture,
            icon: const Icon(Icons.picture_in_picture_alt_rounded),
            label: const Text('Buka di Mode Picture-in-Picture (PiP)'),
          ),
        ],
      ),
    );
  }

  // ── Chat Admin Tab (Placeholder) ───────────────────────────────────────────
  Widget _buildChatTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chat Admin',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Chat Under Development',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

