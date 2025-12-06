import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/theme_config.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'widgets/user_profile_widget.dart';
import 'widgets/change_password_dialog.dart';

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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! Authenticated) {
              return const Center(
                child: Text('Please log in'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              children: [
                // User Profile Card
                UserProfileWidget(user: authState.user),
                const SizedBox(height: AppSizes.paddingXL),

                // Theme Section
                _buildSectionHeader(context, AppStrings.theme),
                const SizedBox(height: AppSizes.paddingS),
                _buildThemeSelector(context),
                const SizedBox(height: AppSizes.paddingXL),

                // Account Section
                _buildSectionHeader(context, AppStrings.account),
                const SizedBox(height: AppSizes.paddingS),
                _buildAccountSettings(context, authState),
                const SizedBox(height: AppSizes.paddingXL),

                // Security Section
                _buildSectionHeader(context, 'Security'),
                const SizedBox(height: AppSizes.paddingS),
                _buildSecuritySettings(context),
                const SizedBox(height: AppSizes.paddingXL),

                // Danger Zone
                _buildSectionHeader(context, 'Danger Zone'),
                const SizedBox(height: AppSizes.paddingS),
                _buildDangerZone(context),
                const SizedBox(height: AppSizes.paddingXL),

                // Logout Button
                _buildLogoutButton(context),
                const SizedBox(height: AppSizes.paddingL),
              ],
            );
          },
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

  Widget _buildAccountSettings(BuildContext context, Authenticated authState) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your name and photo'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showEditProfileDialog(context, authState.user.name ?? '');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text(AppStrings.notifications),
            subtitle: const Text('Manage notification preferences'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications settings coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text(AppStrings.language),
            subtitle: const Text('Change app language'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Change Password'),
            subtitle: const Text('Update your password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(AppStrings.about),
            subtitle: const Text('App version and information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      color: AppColors.error.withOpacity(0.05),
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: AppColors.error),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Permanently delete your account and data'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.error),
        onTap: () {
          _showDeleteAccountDialog(context);
        },
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
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout),
            label: Text(
              state is AuthLoading ? AppStrings.loading : AppStrings.logout,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                try {
                  final authRepo = context.read<AuthRepository>();
                  await authRepo.updateUserProfile(name: newName);

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    // Reload auth state
                    context.read<AuthBloc>().add(const CheckAuthStatus());
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } else {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangePasswordDialog(
        onChangePassword: (currentPassword, newPassword) async {
          final authRepo = context.read<AuthRepository>();
          await authRepo.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: AppSizes.paddingM),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingM),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password to confirm',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your password'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                final authRepo = context.read<AuthRepository>();
                await authRepo.deleteAccount(password);

                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  context.go(AppRoutes.login);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '日本語学習',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primaryRed, AppColors.primaryBlue],
          ),
        ),
        child: const Icon(
          Icons.temple_buddhist,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const SizedBox(height: 16),
        const Text('Learn Japanese through interactive practice and writing.'),
        const SizedBox(height: 8),
        const Text('Master Hiragana and Katakana with stroke-by-stroke guidance.'),
      ],
    );
  }
}