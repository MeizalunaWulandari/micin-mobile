import 'package:flutter/material.dart';
import '../../core/components/provider_content_card.dart';
import '../../core/constants/app_colors.dart';
import '../../models/provider.dart';
import '../../viewmodels/provider_content_viewmodel.dart';

/// Halaman yang menampilkan daftar data konten dari endpoint slug provider
class ProviderContentView extends StatefulWidget {
  final ProviderItem provider;

  const ProviderContentView({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderContentView> createState() => _ProviderContentViewState();
}

class _ProviderContentViewState extends State<ProviderContentView> {
  late final ProviderContentViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = ProviderContentViewModel(
      slug: widget.provider.slug,
      initialTitle: widget.provider.name,
    );
    _vm.addListener(_onViewModelChanged);
    _vm.loadContent();
  }

  @override
  void dispose() {
    _vm.removeListener(_onViewModelChanged);
    _vm.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final title = _vm.title.isNotEmpty ? _vm.title : widget.provider.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _vm.loadContent,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _vm.loadContent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_vm.state) {
      case ContentLoadState.loading:
      case ContentLoadState.idle:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );

      case ContentLoadState.error:
        return Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat konten ${_vm.title}.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _vm.errorMessage,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  onPressed: _vm.loadContent,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );

      case ContentLoadState.empty:
        return const Center(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  color: AppColors.textSecondary,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Tidak ada konten tersedia saat ini.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      case ContentLoadState.success:
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _vm.items.length,
          itemBuilder: (context, index) {
            final item = _vm.items[index];
            return ProviderContentCard(
              item: item,
              onTap: () {
                // Callback jika item diklik
              },
            );
          },
        );
    }
  }
}

