import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/premium_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _loading = false;
  String? _selectedPlanId;

  Future<void> _purchase(StoreProduct product) async {
    setState(() => _loading = true);
    try {
      final success =
          await ref.read(premiumNotifierProvider.notifier).purchase(product);
      if (success && mounted) {
        await _showSuccessDialog();
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.stateCompleted.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 40,
                color: AppColors.stateCompleted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Welcome to Premium!',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'You now have unlimited access to all features.',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: const Text('Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    try {
      final success =
          await ref.read(premiumNotifierProvider.notifier).restore();
      if (mounted) {
        if (success) {
          await _showSuccessDialog();
          if (mounted) Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No purchases to restore')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(premiumProductsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Header
              const Icon(Icons.diamond_rounded,
                  size: 56, color: AppColors.accent),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Unlock Premium',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Get the most out of MyDayfocus',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Feature comparison
              const _FeatureList(),
              const SizedBox(height: AppSpacing.lg),

              // Plan cards
              productsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading products: $e'),
                data: (products) {
                  if (products.isEmpty) {
                    return const Text(
                      'Products not available',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    );
                  }

                  final monthly = products
                      .where((p) => p.identifier.contains('monthly'))
                      .firstOrNull;
                  final yearly = products
                      .where((p) => p.identifier.contains('yearly'))
                      .firstOrNull;

                  // Default to yearly if not selected
                  _selectedPlanId ??= yearly?.identifier ?? monthly?.identifier;

                  final selectedProduct = products.firstWhere(
                    (p) => p.identifier == _selectedPlanId,
                    orElse: () => products.first,
                  );

                  return Column(
                    children: [
                      if (yearly != null)
                        _PlanCard(
                          title: 'Yearly',
                          price: yearly.priceString,
                          period: '/year',
                          badge: 'BEST VALUE',
                          savingsText: _calculateSavings(monthly, yearly),
                          isSelected: _selectedPlanId == yearly.identifier,
                          onTap: () => setState(
                              () => _selectedPlanId = yearly.identifier),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      if (monthly != null)
                        _PlanCard(
                          title: 'Monthly',
                          price: monthly.priceString,
                          period: '/month',
                          isSelected: _selectedPlanId == monthly.identifier,
                          onTap: () => setState(
                              () => _selectedPlanId = monthly.identifier),
                        ),
                      const SizedBox(height: AppSpacing.lg),

                      // Subscribe button
                      FilledButton(
                        onPressed:
                            _loading ? null : () => _purchase(selectedProduct),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Start 7-day free trial',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Cancel anytime. Auto-renews after trial.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _loading ? null : _restore,
                child: const Text('Restore purchases'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  String? _calculateSavings(StoreProduct? monthly, StoreProduct? yearly) {
    if (monthly == null || yearly == null) return null;
    final monthlyAnnual = monthly.price * 12;
    final savings = monthlyAnnual - yearly.price;
    if (savings <= 0) return null;
    final percent = ((savings / monthlyAnnual) * 100).round();
    return 'Save $percent%';
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Column(
        children: [
          _FeatureRow(
            icon: Icons.checklist_rounded,
            title: 'Unlimited Priorities',
            subtitle: 'Free: 3 per day',
          ),
          SizedBox(height: AppSpacing.sm),
          _FeatureRow(
            icon: Icons.schedule_rounded,
            title: 'Unlimited Time Blocks',
            subtitle: 'Free: 5 per day',
          ),
          SizedBox(height: AppSpacing.sm),
          _FeatureRow(
            icon: Icons.history_rounded,
            title: 'Full History Access',
            subtitle: 'Free: Last 7 days',
          ),
          SizedBox(height: AppSpacing.sm),
          _FeatureRow(
            icon: Icons.cloud_sync_rounded,
            title: 'Cross-device Sync',
            subtitle: 'Keep data everywhere',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppColors.stateCompleted,
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.savingsText,
  });

  final String title;
  final String price;
  final String period;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final String? savingsText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.08)
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (savingsText != null)
                    Text(
                      savingsText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.stateCompleted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
