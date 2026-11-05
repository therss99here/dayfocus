import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../analytics/data/analytics_service.dart';
import '../../domain/day_summary.dart';
import '../utils/share_image_renderer.dart';
import '../utils/share_text_formatter.dart';

Future<void> showShareBottomSheet(
  BuildContext context, {
  required DaySummary summary,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) => _ShareSheet(summary: summary, parentContext: context),
  );
}

Rect _shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return Rect.zero;
  final position = box.localToGlobal(Offset.zero);
  return position & box.size;
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.summary, required this.parentContext});
  final DaySummary summary;
  final BuildContext parentContext;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  bool _rendering = false;
  final _textKey = GlobalKey();
  final _imageKey = GlobalKey();

  void _popWhenSafe() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _shareText() async {
    final text = formatDaySummary(widget.summary);
    final origin = _shareOrigin(_textKey.currentContext ?? context);
    await Share.share(text, sharePositionOrigin: origin);
    AnalyticsService.trackDayShared(format: 'text');
    _popWhenSafe();
  }

  Future<void> _shareImage() async {
    setState(() => _rendering = true);
    try {
      final file = await renderShareCard(widget.parentContext, widget.summary);
      if (!mounted) return;
      final origin = _shareOrigin(_imageKey.currentContext ?? context);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My day planned with MyDayfocus',
        sharePositionOrigin: origin,
      );
      AnalyticsService.trackDayShared(format: 'image');
      _popWhenSafe();
    } catch (e) {
      debugPrint('[Share] Image share error: $e');
      if (!mounted) return;
      _popWhenSafe();
      if (!widget.parentContext.mounted) return;
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(content: Text('Could not generate image. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md,
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
            const Text(
              'Share your day',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.md),
            _OptionTile(
              key: _textKey,
              icon: Icons.text_snippet_outlined,
              title: 'Share as Text',
              subtitle: 'Works in messages, email, and notes',
              onTap: _rendering ? null : _shareText,
            ),
            const SizedBox(height: AppSpacing.xs),
            _OptionTile(
              key: _imageKey,
              icon: Icons.image_outlined,
              title: 'Share as Image',
              subtitle: 'Branded card for social media',
              trailing: _rendering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _rendering ? null : _shareImage,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
