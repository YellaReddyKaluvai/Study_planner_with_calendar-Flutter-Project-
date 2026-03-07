import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/splash_page.dart';
import '../../features/auth/domain/user_entity.dart';
import '../../presentation/features/home/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier =
      ValueNotifier<UserEntity?>(ref.watch(currentUserProvider));

  // Update the notifier whenever the currentUserProvider changes
  ref.listen<UserEntity?>(currentUserProvider, (_, next) {
    authNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final currentPath = state.uri.toString();

      // Don't redirect away from splash — it handles its own navigation
      if (currentPath == '/splash') {
        return null;
      }

      final user = ref.read(currentUserProvider);
      final isLoggedIn = user != null && user.isNotEmpty;
      final isLoggingIn = currentPath == '/login';

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
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
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
