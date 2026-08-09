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

  Future<void> _purchase(StoreProduct product) async {
    setState(() => _loading = true);
    try {
      final success = await ref.read(premiumNotifierProvider.notifier).purchase(product);
      if (success && mounted) {
        Navigator.of(context).pop(true);
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

  Future<void> _restore() async {
    setState(() => _loading = true);
    try {
      final success = await ref.read(premiumNotifierProvider.notifier).restore();
      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text('◆',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, color: AppColors.accent)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Unlock MyDayfocus\nPremium',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Unlimited priorities & time blocks\nFull history • Sync across devices',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading products: $e'),
                data: (products) {
                  if (products.isEmpty) {
                    return const Text(
                      'Products not available',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    );
                  }

                  final monthly = products.where(
                    (p) => p.identifier.contains('monthly'),
                  ).firstOrNull;
                  final yearly = products.where(
                    (p) => p.identifier.contains('yearly'),
                  ).firstOrNull;

                  return Column(
                    children: [
                      if (yearly != null)
                        FilledButton(
                          onPressed: _loading ? null : () => _purchase(yearly),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: Text(
                            '${yearly.priceString} / year  — Best value',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      if (monthly != null)
                        FilledButton(
                          onPressed: _loading ? null : () => _purchase(monthly),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: Text('${monthly.priceString} / month'),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: CircularProgressIndicator(),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _loading ? null : _restore,
                child: const Text('Restore purchases'),
              ),
              TextButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                child: const Text('Not now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
