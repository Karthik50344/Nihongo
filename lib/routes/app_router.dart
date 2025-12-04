import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/katakana/katakana_screen.dart';
import '../core/constants/app_routes.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_state.dart';
import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/practice/practice_levels_screen.dart';
import '../presentation/screens/practice/practice_session_screen.dart';
import '../presentation/screens/progress/progress_screen.dart';
import '../presentation/screens/register/register_screen.dart';
import '../presentation/screens/forgot_password/forgot_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/hiragana/hiragana_screen.dart';

/// App router configuration
class AppRouter {
  AppRouter._();

  static GoRouter getRouter(BuildContext context) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: GoRouterRefreshStream(
        context.read<AuthBloc>().stream,
      ),
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthenticated = authState is Authenticated;
        final isGoingToLogin = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.forgotPassword;

        // If not authenticated and trying to access protected routes, redirect to login
        if (!isAuthenticated && !isGoingToLogin) {
          return AppRoutes.login;
        }

        // If authenticated and trying to access login, redirect to home
        if (isAuthenticated && isGoingToLogin) {
          return AppRoutes.home;
        }

        return null; // No redirect needed
      },
      routes: [
        // Login Screen
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          builder: (context, state) => const LoginScreen(),
        ),

        // Register Screen
        GoRoute(
          path: AppRoutes.register,
          name: AppRoutes.registerName,
          builder: (context, state) => const RegisterScreen(),
        ),

        // Forgot Password Screen
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: AppRoutes.forgotPasswordName,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Home Screen
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.homeName,
          builder: (context, state) => const HomeScreen(),
        ),

        // Settings Screen
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settingsName,
          builder: (context, state) => const SettingsScreen(),
        ),

        // Hiragana Screen
        GoRoute(
          path: AppRoutes.hiragana,
          name: AppRoutes.hiraganaName,
          builder: (context, state) => const HiraganaScreen(),
        ),

        // Katakana Screen
        GoRoute(
          path: AppRoutes.katakana,
          name: AppRoutes.katakanaName,
          builder: (context, state) => const KatakanaScreen(),
        ),

        // Practice Levels Screen
        GoRoute(
          path: AppRoutes.practice,
          name: AppRoutes.practiceName,
          builder: (context, state) => const PracticeLevelsScreen(),
        ),

        // Practice Session Screen
        GoRoute(
          path: '${AppRoutes.practiceSession}/:levelId',
          name: AppRoutes.practiceSessionName,
          builder: (context, state) {
            final levelId = state.pathParameters['levelId']!;
            return PracticeSessionScreen(levelId: levelId);
          },
        ),

        // Progress Screen
        GoRoute(
          path: AppRoutes.progress,
          name: AppRoutes.progressName,
          builder: (context, state) => const ProgressScreen(),
        ),
      ],

      // Error handling
      errorBuilder: (context, state) => const LoginScreen(),
    );
  }
}

/// Helper class to refresh GoRouter when auth state changes
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