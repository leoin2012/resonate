import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/history/presentation/history_screen.dart';

/// Route paths
class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String history = '/history';
}

/// App router configuration
class AppRouter {
  /// Create GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.history,
          name: 'history',
          builder: (context, state) => const HistoryScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: Text(
            'Page not found: ${state.uri}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter();
});
