import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/device_detail/device_detail_screen.dart';
import '../presentation/screens/shares/device_shares_screen.dart';
import '../presentation/screens/shares/incoming_shares_screen.dart';
import '../presentation/screens/events/event_history_screen.dart';
import '../presentation/screens/provisioning/provisioning_screen.dart';
import '../presentation/screens/provisioning/ap_setup_screen.dart';
import '../presentation/screens/provisioning/claim_device_screen.dart';
import '../presentation/screens/provisioning/link_device_screen.dart';
import '../presentation/screens/help/help_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';

      if (isLoggedIn && isLoginRoute) return '/';
      if (!isLoggedIn && !isLoginRoute && state.matchedLocation != '/splash') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/device/:id',
        builder: (_, state) => DeviceDetailScreen(
          deviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/device/:id/shares',
        builder: (_, state) => DeviceSharesScreen(
          deviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/device/:id/events',
        builder: (_, state) => EventHistoryScreen(
          deviceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/shares/incoming',
        builder: (_, __) => const IncomingSharesScreen(),
      ),
      GoRoute(
        path: '/provision',
        builder: (_, __) => const ProvisioningScreen(),
      ),
      GoRoute(
        path: '/provision/ap-setup',
        builder: (_, __) => const ApSetupScreen(),
      ),
      GoRoute(
        path: '/provision/claim',
        builder: (_, __) => const ClaimDeviceScreen(),
      ),
      GoRoute(
        path: '/provision/link/:deviceId',
        builder: (_, state) => LinkDeviceScreen(
          deviceId: state.pathParameters['deviceId']!,
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (_, __) => const HelpScreen(),
      ),
    ],
  );
});
