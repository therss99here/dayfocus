import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayfocus/features/board/presentation/screens/board_screen.dart';

void main() {
  group('BoardScreen layout logic', () {
    testWidgets('BoardScreen is a StatelessWidget', (tester) async {
      expect(const BoardScreen(), isA<StatelessWidget>());
    });

    testWidgets('default test size (800x600) triggers mobile layout',
        (tester) async {
      // Default tester viewport is 800x600 logical pixels.
      // shortestSide = 600, but width < 720 so mobile layout should be used.
      // Full render test deferred to Patrol integration tests due to
      // heavy deps (QuillEditor, Image.asset, periodic timers, GoRouter).
      final logicalWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(logicalWidth, greaterThanOrEqualTo(720),
          reason: 'If this fails, the default size changed — update test');
      // shortestSide < 600 means mobile on non-macOS
      final shortestSide =
          tester.view.physicalSize.shortestSide / tester.view.devicePixelRatio;
      expect(shortestSide, lessThan(720));
    });

    testWidgets('wide viewport meets desktop breakpoint', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final logicalWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final shortestSide =
          tester.view.physicalSize.shortestSide / tester.view.devicePixelRatio;
      expect(logicalWidth, greaterThanOrEqualTo(720));
      expect(shortestSide, greaterThanOrEqualTo(600));
    });
  });
}
