import 'package:equatable/equatable.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Email/Password sign in requested
class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const EmailSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Email/Password registration requested
class EmailRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const EmailRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Google sign in requested
class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

/// Facebook sign in requested
class FacebookSignInRequested extends AuthEvent {
  const FacebookSignInRequested();
}

/// Password reset requested
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Sign out requested
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Check authentication status
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}