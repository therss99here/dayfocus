import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../brain_dump/presentation/providers/brain_dump_provider.dart';
import '../../../priorities/presentation/widgets/priority_list.dart';
import '../../../timeline/presentation/widgets/timeline_widget.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // macOS always uses the two-panel layout. Phones in landscape can exceed
    // 720pt width but are not tablets — keep them on the mobile layout.
    final isMacOS =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final isWide =
        isMacOS || (size.width >= 720 && size.shortestSide >= 600);
    return Scaffold(
      body: isWide ? const _DesktopLayout() : const _MobileLayout(),
    );
  }
}

// ── Desktop ───────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: AppSpacing.leftPanelWidth,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: const _LeftPanel(),
          ),
        ),
        const VerticalDivider(width: 1),
        const Expanded(child: TimelineWidget()),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AppHeader(),
        const Divider(height: 1),
        const _SectionLabel('TOP PRIORITIES'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: PriorityList(),
        ),
        const Divider(height: 1),
        const _SectionLabel('BRAIN DUMP'),
        const Expanded(child: _BrainDump()),
      ],
    );
  }
}

// ── Mobile ────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const _AppHeader(),
          const Divider(height: 1),
          _PrioritiesExpansion(),
          const Divider(height: 1),
          _BrainDumpExpansion(),
          const Divider(height: 1),
          const Expanded(child: TimelineWidget()),
        ],
      ),
    );
  }
}

class _BrainDumpExpansion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      title: const Text(
        'BRAIN DUMP',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.4,
        ),
      ),
      children: const [
        SizedBox(
          height: 140,
          child: _BrainDump(),
        ),
      ],
    );
  }
}

class _PrioritiesExpansion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      title: const Text(
        "TODAY'S PRIORITIES",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.4,
        ),
      ),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: PriorityList(),
        ),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Text(
            '◆ MyDayfocus',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push(AppRoutes.settings),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.settings_outlined,
                  size: 17, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm, 12, AppSpacing.sm, 4,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _BrainDump extends ConsumerStatefulWidget {
  const _BrainDump();

  @override
  ConsumerState<_BrainDump> createState() => _BrainDumpState();
}

class _BrainDumpState extends ConsumerState<_BrainDump> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String? _lastSyncedContent;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value != _lastSyncedContent) {
        _lastSyncedContent = value;
        ref.read(brainDumpNotifierProvider.notifier).save(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String?>>(brainDumpNotifierProvider, (prev, next) {
      final content = next.valueOrNull ?? '';
      if (content != _controller.text && content != _lastSyncedContent) {
        _controller.text = content;
        _lastSyncedContent = content;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        maxLines: null,
        expands: true,
        style: const TextStyle(fontSize: 13, height: 1.6),
        decoration: const InputDecoration(
          hintText: 'Dump ideas, notes, anything...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
