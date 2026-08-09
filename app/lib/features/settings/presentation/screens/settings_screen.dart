import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_bottom_sheet.dart';
import '../providers/notification_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: const [
          SizedBox(height: AppSpacing.sm),
          _SyncSection(),
          SizedBox(height: AppSpacing.md),
          _NotificationsSection(),
          SizedBox(height: AppSpacing.md),
          _AboutSection(),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ── Sync / Account ────────────────────────────────────────────────────────────

class _SyncSection extends ConsumerWidget {
  const _SyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return _Section(
      label: 'SYNC & ACCOUNT',
      children: user == null
          ? [
              _ActionTile(
                title: 'Connect & Sync',
                subtitle: 'Back up your data across devices',
                icon: Icons.cloud_upload_outlined,
                iconColor: AppColors.accent,
                onTap: () => showAuthBottomSheet(context),
              ),
            ]
          : [
              _InfoTile(
                label: 'Signed in as',
                value: user.email ?? user.id.substring(0, 8),
              ),
              const _Divider(),
              _ActionTile(
                title: 'Sign out',
                subtitle: 'Data remains on this device',
                icon: Icons.logout,
                iconColor: AppColors.stateMissed,
                onTap: () => ref
                    .read(authNotifierProvider.notifier)
                    .signOut(),
              ),
            ],
    );
  }
}

// ── Notifications ─────────────────────────────────────────────────────────────

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync =
        ref.watch(notificationSettingsNotifierProvider);
    final notifier =
        ref.read(notificationSettingsNotifierProvider.notifier);

    return settingsAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text('Could not load settings',
            style: TextStyle(color: AppColors.stateMissed, fontSize: 13)),
      ),
      data: (s) => _Section(
        label: 'NOTIFICATIONS',
        children: [
          _ToggleTile(
            title: 'Morning reminder',
            subtitle: 'Plan your day before it starts',
            value: s.morningEnabled,
            onChanged: notifier.setMorningEnabled,
          ),
          if (s.morningEnabled)
            _TimeTile(
              label: 'Reminder time',
              time: s.morningTime,
              onTap: () => _pickTime(
                context,
                initial: s.morningTime,
                onPicked: notifier.setMorningTime,
              ),
            ),
          const _Divider(),
          _ToggleTile(
            title: 'Evening review',
            subtitle: 'Reflect on your completed blocks',
            value: s.eveningEnabled,
            onChanged: notifier.setEveningEnabled,
          ),
          if (s.eveningEnabled)
            _TimeTile(
              label: 'Review time',
              time: s.eveningTime,
              onTap: () => _pickTime(
                context,
                initial: s.eveningTime,
                onPicked: notifier.setEveningTime,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay initial,
    required void Function(TimeOfDay) onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }
}

// ── About ─────────────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      label: 'ABOUT',
      children: [
        _InfoTile(label: 'Version', value: '1.0.0'),
      ],
    );
  }
}

// ── Shared building blocks ────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.xs),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accentDim,
          ),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = time.format(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 2),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textMuted)),
            ),
            Text(formatted,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 14),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 15))),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: iconColor == AppColors.stateMissed
                              ? AppColors.stateMissed
                              : null)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: AppSpacing.sm);
  }
}
