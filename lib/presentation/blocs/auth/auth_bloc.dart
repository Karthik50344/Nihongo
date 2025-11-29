import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/constants/app_strings.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<EmailSignInRequested>(_onEmailSignIn);
    on<EmailRegisterRequested>(_onEmailRegister);
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<FacebookSignInRequested>(_onFacebookSignIn);
    on<PasswordResetRequested>(_onPasswordReset);
    on<SignOutRequested>(_onSignOut);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  /// Handle email/password sign in
  Future<void> _onEmailSignIn(
      EmailSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_getErrorMessage(e.toString())));
    }
  }

  /// Handle email/password registration
  Future<void> _onEmailRegister(
      EmailRegisterRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(_getErrorMessage(e.toString())));
    }
  }

  /// Handle Google sign in
  Future<void> _onGoogleSignIn(
      GoogleSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(Authenticated(user));
    } catch (e) {
      emit(const AuthError(AppStrings.googleSignInFailed));
    }
  }

  /// Handle Facebook sign in
  Future<void> _onFacebookSignIn(
      FacebookSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.signInWithFacebook();
      emit(Authenticated(user));
    } catch (e) {
      emit(const AuthError(AppStrings.facebookSignInFailed));
    }
  }

  /// Handle password reset
  Future<void> _onPasswordReset(
      PasswordResetRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(const PasswordResetSent());
    } catch (e) {
      emit(const AuthError(AppStrings.resetEmailFailed));
    }
  }

  /// Handle sign out
  Future<void> _onSignOut(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signOut();
      emit(const SignOutSuccess());
    } catch (e) {
      emit(AuthError('Sign out failed: ${e.toString()}'));
    }
  }

  /// Check authentication status
  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No user found with this email';
    } else if (error.contains('wrong-password')) {
      return 'Wrong password provided';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid Email or Password';
    }
    return 'Authentication failed. Please try again';
  }
}