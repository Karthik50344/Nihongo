import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/theme_config.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is SignOutSuccess) {
            context.go(AppRoutes.login);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            // Theme Section
            _buildSectionHeader(context, AppStrings.theme),
            const SizedBox(height: AppSizes.paddingS),
            _buildThemeSelector(context),
            const SizedBox(height: AppSizes.paddingXL),

            // Account Section
            _buildSectionHeader(context, AppStrings.account),
            const SizedBox(height: AppSizes.paddingS),
            _buildAccountSettings(context),
            const SizedBox(height: AppSizes.paddingXL),

            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: AppColors.primaryRed,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        AppThemeMode currentTheme = AppThemeMode.system;
        if (state is ThemeLoaded) {
          currentTheme = state.themeMode;
        }

        return Card(
          child: Column(
            children: [
              _buildThemeTile(
                context: context,
                title: AppStrings.lightTheme,
                icon: Icons.light_mode,
                themeMode: AppThemeMode.light,
                currentTheme: currentTheme,
              ),
              const Divider(height: 1),
              _buildThemeTile(
                context: context,
                title: AppStrings.darkTheme,
                icon: Icons.dark_mode,
                themeMode: AppThemeMode.dark,
                currentTheme: currentTheme,
              ),
              const Divider(height: 1),
              _buildThemeTile(
                context: context,
                title: AppStrings.systemTheme,
                icon: Icons.brightness_auto,
                themeMode: AppThemeMode.system,
                currentTheme: currentTheme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required AppThemeMode themeMode,
    required AppThemeMode currentTheme,
  }) {
    final isSelected = themeMode == currentTheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryRed : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primaryRed : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primaryRed)
          : null,
      onTap: () {
        context.read<ThemeBloc>().add(ChangeTheme(themeMode));
      },
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text(AppStrings.notifications),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text(AppStrings.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(AppStrings.about),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: state is AuthLoading
                ? null
                : () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(AppStrings.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<AuthBloc>().add(const SignOutRequested());
                      },
                      child: const Text(
                        AppStrings.logout,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: Text(
              state is AuthLoading ? AppStrings.loading : AppStrings.logout,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
          ),
        );
      },
    );
  }
}