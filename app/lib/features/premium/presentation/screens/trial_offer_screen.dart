import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../analytics/data/analytics_service.dart';
import '../providers/premium_provider.dart';
import '../screens/premium_screen.dart';

class TrialOfferScreen extends ConsumerStatefulWidget {
  const TrialOfferScreen({super.key});

  @override
  ConsumerState<TrialOfferScreen> createState() => _TrialOfferScreenState();
}

class _TrialOfferScreenState extends ConsumerState<TrialOfferScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.trackPaywallViewed(source: 'post_onboarding');
  }

  void _continue() {
    context.go('/');
  }

  void _startTrial() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    ).then((_) {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(premiumProductsProvider);
    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColors.textPrimaryLight;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _continue,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.accentDim,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  size: 44,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              productsAsync.when(
                data: (products) {
                  final yearly = products
                      .where((p) => p.identifier.contains('yearly'))
                      .firstOrNull;
                  final hasTrial = yearly?.introductoryPrice != null &&
                      yearly!.introductoryPrice!.price == 0;
                  return Column(
                    children: [
                      Text(
                        hasTrial
                            ? 'Try Premium free\nfor 7 days'
                            : 'Unlock Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        hasTrial
                            ? 'Unlock everything. Cancel anytime.'
                            : 'Get the most out of MyDayfocus.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Column(
                  children: [
                    Text(
                      'Unlock Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Get the most out of MyDayfocus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                error: (_, __) => Column(
                  children: [
                    Text(
                      'Unlock Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Get the most out of MyDayfocus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Feature list
              const _FeatureRow(
                icon: Icons.checklist_rounded,
                text: 'Unlimited priorities & time blocks',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _FeatureRow(
                icon: Icons.history_rounded,
                text: 'Full history access',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _FeatureRow(
                icon: Icons.cloud_sync_rounded,
                text: 'Cross-device sync',
              ),
              const Spacer(flex: 3),
              // CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _startTrial,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: productsAsync.when(
                    data: (products) {
                      final yearly = products
                          .where((p) => p.identifier.contains('yearly'))
                          .firstOrNull;
                      final hasTrial = yearly?.introductoryPrice != null &&
                          yearly!.introductoryPrice!.price == 0;
                      return Text(
                        hasTrial
                            ? 'Start free trial — ${yearly.priceString}/year'
                            : yearly != null
                                ? 'Subscribe — ${yearly.priceString}/year'
                                : 'Subscribe now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                    loading: () => const Text(
                      'View plans',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    error: (_, __) => const Text(
                      'View plans',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: _continue,
                child: const Text(
                  'Maybe later',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentDim,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
