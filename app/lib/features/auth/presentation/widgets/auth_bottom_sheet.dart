import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../providers/auth_provider.dart';

/// Shows the auth bottom sheet and returns after sign-in (or dismissal).
Future<void> showAuthBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AuthBottomSheet(),
  );
}

class AuthBottomSheet extends ConsumerStatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  ConsumerState<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends ConsumerState<AuthBottomSheet> {
  bool _loading = false;
  String? _error;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
      // Sync data after successful sign-in
      await ref.read(syncNotifierProvider.notifier).syncNow();
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      // Supabase auth error — has a structured message
      debugPrint('[Auth] Supabase error: ${e.message} (${e.statusCode})');
      if (mounted) setState(() => _error = e.message);
    } catch (e, st) {
      final msg = e.toString();
      debugPrint('[Auth] Error: $msg\n$st');

      final isCancelled = msg.contains('canceled') ||
          msg.contains('cancelled') ||
          msg.contains('AuthorizationErrorCode.canceled') ||
          msg.contains('com.apple.AuthenticationServices.AuthorizationError error 1001');
      if (mounted && !isCancelled) {
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Brand
          const Text(
            '◆ MyDayfocus',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Headline
          const Text(
            'Sign in to sync your data',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Your tasks stay on this device until you connect.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.stateMissedDim,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.stateMissed),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Apple button
          _AuthButton(
            onTap: _loading
                ? null
                : () => _run(ref.read(authNotifierProvider.notifier).signInWithApple),
            icon: Icons.apple,
            label: 'Continue with Apple',
            filled: true,
          ),

          const SizedBox(height: AppSpacing.xs),

          // Google button
          _AuthButton(
            onTap: _loading
                ? null
                : () => _run(ref.read(authNotifierProvider.notifier).signInWithGoogle),
            icon: Icons.g_mobiledata,
            label: 'Continue with Google',
            filled: false,
          ),

          if (_loading) ...[
            const SizedBox(height: AppSpacing.sm),
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Legal footnote
          Text(
            'By signing in you agree to our Privacy Policy and Terms of Service.',
            style: TextStyle(
                fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : null;
    final bg = filled ? Colors.black : Colors.transparent;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: BorderSide(
            color: filled
                ? Colors.black
                : AppColors.textMuted.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
