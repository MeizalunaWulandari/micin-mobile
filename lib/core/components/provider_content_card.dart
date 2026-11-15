import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/provider_content_model.dart';

/// Kartu konten dinamis yang secara adaptif menampilkan:
/// - Kartu bergambar (Image Card) jika [item.hasImage] bernilai `true`.
/// - Kartu biasa (Text Card) jika [item.hasImage] bernilai `false`.
class ProviderContentCard extends StatelessWidget {
  final ProviderContentItem item;
  final VoidCallback? onTap;

  const ProviderContentCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool showImage = item.hasImage && item.thumbnail.isNotEmpty;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: showImage ? _buildImageCard(context) : _buildTextCard(context),
      ),
    );
  }

  // ── Kartu Bergambar (has_image == true) ──────────────────────────────────────
  Widget _buildImageCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail Image Banner
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                item.thumbnail,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: AppColors.textSecondary,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Status overlay tag
            Positioned(
              top: 10,
              right: 10,
              child: _buildStatusBadge(item.status),
            ),
            // Category overlay tag
            if (item.category.isNotEmpty)
              Positioned(
                top: 10,
                left: 10,
                child: _buildCategoryBadge(item.category),
              ),
          ],
        ),

        // Info Section
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (item.description.isNotEmpty && item.description != item.title) ...[
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
              if (item.schedule.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.schedule,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Kartu Biasa (has_image == false) ─────────────────────────────────────────
  Widget _buildTextCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Badges (Category & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.category.isNotEmpty)
                _buildCategoryBadge(item.category)
              else
                const SizedBox.shrink(),
              _buildStatusBadge(item.status),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Description
          Text(
            item.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          if (item.description.isNotEmpty && item.description != item.title) ...[
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (item.schedule.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  item.schedule,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Badges ──────────────────────────────────────────────────────────────────
  Widget _buildCategoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isUpcoming = status.toLowerCase() == 'upcoming';
    final isEnded = status.toLowerCase() == 'ended';
    final Color badgeColor = isUpcoming
        ? AppColors.secondary
        : (isEnded ? AppColors.textSecondary : AppColors.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

