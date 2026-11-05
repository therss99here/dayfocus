import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/day_summary.dart';
import '../widgets/share_card_widget.dart';

Future<File> renderShareCard(
  BuildContext context,
  DaySummary summary,
) async {
  final boundaryKey = GlobalKey();

  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -ShareCardWidget.cardWidth * 4,
      top: -ShareCardWidget.cardHeight * 4,
      width: ShareCardWidget.cardWidth,
      height: ShareCardWidget.cardHeight,
      child: RepaintBoundary(
        key: boundaryKey,
        child: MediaQuery(
          data: const MediaQueryData(),
          child: Material(
            color: Colors.transparent,
            child: ShareCardWidget(summary: summary),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  debugPrint('[Share] Overlay entry inserted, waiting for render...');

  // Wait for layout + paint
  await Future.delayed(const Duration(milliseconds: 300));
  await WidgetsBinding.instance.endOfFrame;

  try {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      debugPrint('[Share] RenderRepaintBoundary is null');
      throw Exception('Could not find render boundary');
    }

    debugPrint('[Share] Rendering to image...');
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('Could not encode image');

    final dir = await getTemporaryDirectory();
    for (final f in dir.listSync().whereType<File>()) {
      if (f.path.contains('mydayfocus_share_')) {
        try {
          await f.delete();
        } catch (_) {}
      }
    }

    final file = File(
      '${dir.path}/mydayfocus_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List());
    debugPrint('[Share] Image saved: ${file.path} (${byteData.lengthInBytes} bytes)');

    return file;
  } finally {
    entry.remove();
    debugPrint('[Share] Overlay entry removed');
  }
}
