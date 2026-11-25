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
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/households/households_screen.dart';
import '../presentation/screens/shares/household_shares_screen.dart';
import 'app_route_observer.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // Recreating GoRouter on auth changes remounts /splash forever (same
  // GlobalKey + initialLocation). Refresh the existing router instead.
  final refresh = ValueNotifier<int>(0);
  ref.listen<bool>(isAuthenticatedProvider, (_, __) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [appRouteObserver],
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoggedIn = ref.read(isAuthenticatedProvider);
      final loc = state.matchedLocation;
      final isLoginRoute = loc == '/login';
      final isSplash = loc == '/splash';
      final isOnboarding = loc == '/onboarding';

      if (isLoggedIn && isLoginRoute) return '/';
      if (!isLoggedIn && !isLoginRoute && !isSplash && !isOnboarding) {
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
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
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
        path: '/households',
        builder: (_, __) => const HouseholdsScreen(),
      ),
      GoRoute(
        path: '/household/:id/shares',
        builder: (_, state) => HouseholdSharesScreen(
          householdId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/provision',
        builder: (_, __) => const ProvisioningScreen(),
      ),
      GoRoute(
        path: '/provision/ap-setup',
        builder: (_, state) => ApSetupScreen(
          initialSerial: state.uri.queryParameters['serial'],
          initialName: state.uri.queryParameters['name'],
          wifiOnly: state.uri.queryParameters['wifiOnly'] == '1',
        ),
      ),
      GoRoute(
        path: '/provision/claim',
        builder: (_, state) => ClaimDeviceScreen(
          initialSerial: state.uri.queryParameters['serial'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),
      // Deep link alias: smartplug://claim?serial=&token=
      GoRoute(
        path: '/claim',
        redirect: (context, state) {
          final q = state.uri.query;
          return q.isEmpty ? '/provision/claim' : '/provision/claim?$q';
        },
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
