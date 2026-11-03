import 'package:go_router/go_router.dart';
import '../../features/board/presentation/screens/board_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/premium/presentation/screens/trial_offer_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

abstract class AppRoutes {
  static const board = '/';
  static const onboarding = '/onboarding';
  static const trialOffer = '/trial-offer';
  static const settings = '/settings';
  static const premium = '/premium';
}

GoRouter buildRouter({required bool showOnboarding}) => GoRouter(
      initialLocation:
          showOnboarding ? AppRoutes.onboarding : AppRoutes.board,
      routes: [
        GoRoute(
          path: AppRoutes.board,
          builder: (context, state) => const BoardScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.trialOffer,
          builder: (context, state) => const TrialOfferScreen(),
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
