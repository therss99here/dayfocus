import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../timeline/presentation/providers/active_day_provider.dart';
import '../providers/brain_dump_provider.dart';

class BrainDumpWidget extends ConsumerStatefulWidget {
  const BrainDumpWidget({super.key});

  @override
  ConsumerState<BrainDumpWidget> createState() => _BrainDumpWidgetState();
}

class _BrainDumpWidgetState extends ConsumerState<BrainDumpWidget> {
  QuillController? _controller;
  Timer? _debounce;
  String? _lastDayId;
  StreamSubscription? _changesSub;

  @override
  void dispose() {
    _debounce?.cancel();
    _changesSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _initController(String deltaJson) {
    _changesSub?.cancel();
    _controller?.dispose();

    Document doc;
    try {
      doc = Document.fromJson(jsonDecode(deltaJson) as List);
    } catch (_) {
      doc = Document();
    }

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _changesSub = _controller!.document.changes.listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        final delta = _controller!.document.toDelta().toJson();
        ref.read(brainDumpNotifierProvider.notifier).save(jsonEncode(delta));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeDay = ref.watch(activeDayProvider);
    final currentDayId = formatDayId(activeDay);
    final contentAsync = ref.watch(brainDumpNotifierProvider);

    return contentAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const Text('Could not load notes. Please try again.'),
      data: (content) {
        if (_lastDayId != currentDayId) {
          _lastDayId = currentDayId;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _initController(content.deltaJson));
            }
          });

          if (_controller == null) {
            return const SizedBox.shrink();
          }
        }

        if (_controller == null) return const SizedBox.shrink();

        return Column(
          children: [
            _BrainDumpToolbar(controller: _controller!),
            const Divider(height: 1),
            Expanded(
              child: QuillEditor.basic(
                controller: _controller!,
                config: QuillEditorConfig(
                  placeholder: 'Dump ideas, notes, anything...',
                  padding: const EdgeInsets.only(top: 8),
                  expands: true,
                  scrollable: true,
                  customStyles: DefaultStyles(
                    paragraph: DefaultTextBlockStyle(
                      const TextStyle(fontSize: 13, height: 1.6),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                    h1: DefaultTextBlockStyle(
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(8, 4),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                    h2: DefaultTextBlockStyle(
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(6, 2),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                    placeHolder: DefaultTextBlockStyle(
                      const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textMuted),
                      HorizontalSpacing.zero,
                      const VerticalSpacing(0, 0),
                      const VerticalSpacing(0, 0),
                      null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BrainDumpToolbar extends StatelessWidget {
  const _BrainDumpToolbar({required this.controller});

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return QuillSimpleToolbar(
      controller: controller,
      config: QuillSimpleToolbarConfig(
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showStrikeThrough: true,
        showHeaderStyle: true,
        showListBullets: true,
        showListNumbers: true,
        showFontFamily: false,
        showFontSize: false,
        showColorButton: false,
        showBackgroundColorButton: false,
        showClearFormat: false,
        showAlignmentButtons: false,
        showLeftAlignment: false,
        showCenterAlignment: false,
        showRightAlignment: false,
        showJustifyAlignment: false,
        showListCheck: false,
        showCodeBlock: false,
        showQuote: false,
        showIndent: false,
        showLink: false,
        showUndo: false,
        showRedo: false,
        showSearchButton: false,
        showSubscript: false,
        showSuperscript: false,
        showInlineCode: false,
        showSmallButton: false,
        showDirection: false,
        showLineHeightButton: false,
        showDividers: false,
        multiRowsDisplay: false,
        toolbarSectionSpacing: 0,
        headerStyleType: HeaderStyleType.buttons,
        iconTheme: QuillIconTheme(
          iconButtonSelectedData: IconButtonData(
            iconSize: 16,
            color: AppColors.accent,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.accentDim),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
              minimumSize: const WidgetStatePropertyAll(Size(28, 28)),
            ),
          ),
          iconButtonUnselectedData: IconButtonData(
            iconSize: 16,
            color: AppColors.textMuted,
            style: const ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.all(4)),
              minimumSize: WidgetStatePropertyAll(Size(28, 28)),
            ),
          ),
        ),
      ),
    );
  }
}
