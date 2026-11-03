import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../analytics/data/analytics_service.dart';
import '../providers/premium_provider.dart';
import '../screens/premium_screen.dart';

Future<void> showPremiumGate(
  BuildContext context, {
  required String title,
  required String message,
  required String source,
}) async {
  AnalyticsService.trackPaywallViewed(source: source);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _PremiumGateSheet(
      title: title,
      message: message,
      source: source,
    ),
  );
}

class _PremiumGateSheet extends ConsumerWidget {
  const _PremiumGateSheet({
    required this.title,
    required this.message,
    required this.source,
  });

  final String title;
  final String message;
  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(premiumProductsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.accentDim,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond_rounded,
                size: 32,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Benefits row
            const Row(
              children: [
                Expanded(child: _BenefitChip(icon: Icons.all_inclusive, label: 'Unlimited')),
                SizedBox(width: AppSpacing.xs),
                Expanded(child: _BenefitChip(icon: Icons.history, label: 'Full history')),
                SizedBox(width: AppSpacing.xs),
                Expanded(child: _BenefitChip(icon: Icons.cloud_sync, label: 'Sync')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Trial CTA
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: productsAsync.when(
                  data: (products) {
                    final yearly = products
                        .where((p) => p.identifier.contains('yearly'))
                        .firstOrNull;
                    return Text(
                      yearly != null
                          ? 'Start free trial — ${yearly.priceString}/year'
                          : 'Start 7-day free trial',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                  loading: () => const Text(
                    'Start 7-day free trial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  error: (_, __) => const Text(
                    'Start 7-day free trial',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Maybe later',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
