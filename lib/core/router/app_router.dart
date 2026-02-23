import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../presentation/features/home/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = ref.read(currentUserProvider) != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
