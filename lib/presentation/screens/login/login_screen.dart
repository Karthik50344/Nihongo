import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/loading_indicator.dart';
import 'widgets/torii_gate_widget.dart';
import 'widgets/social_button_widget.dart';

/// Login screen with Japanese theme
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: AppSizes.animationSlowest),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        EmailSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXL),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Japanese Gate Animation
                          const ToriiGateWidget(),
                          const SizedBox(height: AppSizes.paddingXXL),

                          // Title
                          Text(
                            AppStrings.loginTitle,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppColors.primaryRed,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingS),
                          Text(
                            AppStrings.loginSubtitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primaryBlue,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingXXL),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: AppStrings.emailLabel,
                              hintText: AppStrings.emailHint,
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: Validators.validateEmail,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSizes.paddingM),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.passwordLabel,
                              hintText: AppStrings.passwordHint,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: Validators.validatePassword,
                            onFieldSubmitted: (_) => _submitForm(),
                          ),
                          const SizedBox(height: AppSizes.paddingS),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.go(AppRoutes.forgotPassword),
                              child: Text(
                                AppStrings.forgotPassword,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingM),

                          // Sign In Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const LoadingIndicator();
                              }

                              return SizedBox(
                                width: double.infinity,
                                height: AppSizes.buttonHeight,
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  child: const Text(AppStrings.signIn),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSizes.paddingL),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.dontHaveAccount,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoutes.register),
                                child: Text(
                                  AppStrings.signUp,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingL),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingM,
                                ),
                                child: Text(
                                  AppStrings.orContinueWith,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingL),

                          // Google Sign In Button
                          SocialButtonWidget(
                            icon: FontAwesomeIcons.google,
                            label: AppStrings.continueWithGoogle,
                            color: AppColors.googleBlue,
                            onPressed: () {
                              context.read<AuthBloc>().add(const GoogleSignInRequested());
                            },
                          ),
                          // const SizedBox(height: AppSizes.paddingL),
                          // Facebook Sign In Button
                          // SocialButtonWidget(
                          //   icon: Icons.facebook,
                          //   label: AppStrings.continueWithFacebook,
                          //   color: AppColors.facebookBlue,
                          //   onPressed: () {
                          //     context.read<AuthBloc>().add(const FacebookSignInRequested());
                          //   },
                          // ),
                          const SizedBox(height: AppSizes.paddingXXL),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}