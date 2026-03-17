import 'package:go_router/go_router.dart';

import '../../features/browser/presentation/first_run_screen.dart';
import '../../features/home/presentation/browser_home_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const BrowserHomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => FirstRunScreen(
        onComplete: () => GoRouter.of(context).go('/'),
      ),
    ),
  ],
);
