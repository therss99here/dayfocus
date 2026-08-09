import 'package:go_router/go_router.dart';
import '../../features/board/presentation/screens/board_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';

abstract class AppRoutes {
  static const board = '/';
  static const settings = '/settings';
  static const premium = '/premium';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.board,
  routes: [
    GoRoute(
      path: AppRoutes.board,
      builder: (context, state) => const BoardScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.premium,
      builder: (context, state) => const PremiumScreen(),
    ),
  ],
);
