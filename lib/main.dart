import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart'; // Import ThemeProvider
import 'core/router/app_router.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/navigation_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/gamification_provider.dart';
import 'presentation/providers/analytics_provider.dart';
import 'services/focus_timer_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Riverpod Scope
    const ProviderScope(
      child: StudyPlannerApp(),
    ),
  );
}

class StudyPlannerApp extends ConsumerWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    // Keep existing Providers for legacy code compatibility
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => NavigationProvider()),
        provider.ChangeNotifierProvider(create: (_) => GamificationProvider()),
        provider.ChangeNotifierProvider(create: (_) => ChatProvider()),
        provider.ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        provider.ChangeNotifierProvider(create: (_) => FocusTimerService()),
        provider.ChangeNotifierProxyProvider<GamificationProvider,
            TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, gamification, taskProvider) =>
              taskProvider!..updateGamification(gamification),
        ),
      ],
      child: MaterialApp.router(
        title: 'Study Planner Ultra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
