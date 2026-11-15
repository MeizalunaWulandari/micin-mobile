import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/components/provider_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/provider.dart';
import '../../viewmodels/provider_viewmodel.dart';
import '../provider_content/provider_content_view.dart';

/// View utama aplikasi — mengintegrasikan:
/// • Auto update check saat startup.
/// • Non-dismissable forced-update modal.
/// • Daftar Reusable Provider Card (hanya is_publish == true).
/// • Version-guard saat card diklik.
/// • Navigasi ke halaman konten provider (BASE_URL/slug).
/// • Footer status versi aplikasi & copyright.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final ProviderViewModel _vm;
  bool _forceUpdateDialogShown = false;

  @override
  void initState() {
    super.initState();
    _vm = ProviderViewModel();
    _vm.addListener(_onViewModelChanged);
    _vm.init();
  }

  @override
  void dispose() {
    _vm.removeListener(_onViewModelChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    // Tampilkan forced-update dialog satu kali, setelah pengecekan selesai
    if (!_vm.checkingUpdate && _vm.hasForceUpdate && !_forceUpdateDialogShown) {
      _forceUpdateDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showForceUpdateDialog(
          _vm.updateData!.updateUrl,
          _vm.updateData!.updateMessage,
        );
      });
    }
    if (mounted) setState(() {});
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showForceUpdateDialog(String updateUrl, String updateMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false, // non-dismissable
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Update Diperlukan',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            updateMessage.isNotEmpty
                ? updateMessage
                : 'Versi baru aplikasi tersedia. Harap perbarui untuk melanjutkan.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Update Sekarang'),
              onPressed: () async {
                final uri = Uri.tryParse(updateUrl);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateRequiredSnackBar(ProviderItem provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Fitur "${provider.name}" memerlukan pembaruan aplikasi.',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.primary,
          onPressed: () {},
        ),
      ),
    );
  }

  // ── Provider Tap Handler ───────────────────────────────────────────────────

  void _handleProviderTap(ProviderItem provider) {
    if (!_vm.canAccessProvider(provider)) {
      _showUpdateRequiredSnackBar(provider);
      return;
    }

    // Navigasi ke halaman konten provider berdasarkan slug
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderContentView(provider: provider),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading saat sedang mengecek update
    if (_vm.checkingUpdate) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Memeriksa pembaruan...',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _vm.loadProviders,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Pilih Provider',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih sumber konten yang ingin Anda gunakan.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Provider list area
            Expanded(child: _buildProviderList()),

            // Footer (Version & Copyright)
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderList() {
    switch (_vm.providerState) {
      case ProviderLoadState.loading:
      case ProviderLoadState.idle:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );

      case ProviderLoadState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Gagal memuat provider.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _vm.loadProviders,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );

      case ProviderLoadState.empty:
        return const Center(
          child: Text(
            'Tidak ada provider tersedia.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        );

      case ProviderLoadState.success:
        return ListView.builder(
          itemCount: _vm.providers.length,
          itemBuilder: (context, index) {
            final provider = _vm.providers[index];
            return ProviderCard(
              provider: provider,
              onTap: () => _handleProviderTap(provider),
            );
          },
        );
    }
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final currentYear = DateTime.now().year;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          // Version information row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'v${_vm.currentVersionName}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              _buildVersionStatusBadge(),
            ],
          ),
          const SizedBox(height: 4),
          // Copyright notice
          Text(
            'Copyright © $currentYear - Micin Project',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionStatusBadge() {
    if (_vm.isUpdateAvailable) {
      return InkWell(
        onTap: () async {
          final url = _vm.updateData?.updateUrl;
          if (url != null && url.isNotEmpty) {
            final uri = Uri.tryParse(url);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primary, width: 0.8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upgrade_rounded, size: 12, color: AppColors.primary),
              SizedBox(width: 3),
              Text(
                'Update Tersedia',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.success, width: 0.8),
      ),
      child: const Text(
        'Latest',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
