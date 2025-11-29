import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nihongo/firebase_options.dart';
import 'package:nihongo/presentation/blocs/auth/auth_event.dart';
import 'core/theme/theme_config.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/theme_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase here when ready
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const JapaneseLearnApp());
}

class JapaneseLearnApp extends StatelessWidget {
  const JapaneseLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => ThemeRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
            )..add(CheckAuthStatus() as AuthEvent), // Check auth on startup
          ),
          BlocProvider(
            create: (context) => ThemeBloc(
              context.read<ThemeRepository>(),
            )..add(LoadTheme()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: '日本語学習',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _getThemeMode(state),
              routerConfig: AppRouter.getRouter(context),
            );
          },
        ),
      ),
    );
  }

  ThemeMode _getThemeMode(ThemeState state) {
    if (state is ThemeLoaded) {
      switch (state.themeMode) {
        case AppThemeMode.light:
          return ThemeMode.light;
        case AppThemeMode.dark:
          return ThemeMode.dark;
        case AppThemeMode.system:
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }
}