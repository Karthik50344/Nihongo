import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nihongo/firebase_options.dart';
import 'package:nihongo/presentation/blocs/auth/auth_event.dart';
import 'core/theme/theme_config.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/theme_repository.dart';
import 'data/repositories/practice_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/blocs/practice/practice_bloc.dart';
import 'presentation/blocs/progress/progress_bloc.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
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
        RepositoryProvider(create: (context) => PracticeRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              context.read<AuthRepository>(),
            )..add(const CheckAuthStatus()),
          ),
          BlocProvider(
            create: (context) => ThemeBloc(
              context.read<ThemeRepository>(),
            )..add(const LoadTheme()),
          ),
          BlocProvider(
            create: (context) => PracticeBloc(
              context.read<PracticeRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProgressBloc(
              context.read<PracticeRepository>(),
            ),
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