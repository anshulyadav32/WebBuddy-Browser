import 'package:go_router/go_router.dart';

import '../../features/home/presentation/browser_home_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const BrowserHomeScreen(),
    ),
  ],
);
