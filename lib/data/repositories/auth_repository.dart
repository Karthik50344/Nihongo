import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Authentication repository
class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Real Firebase implementation:
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User not found');

      return UserModel(
        id: user.uid,
        email: user.email!,
        name: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  /// Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Real Firebase implementation:
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('User creation failed');

      // Update display name
      await user.updateDisplayName(name);

      return UserModel(
        id: user.uid,
        email: user.email!,
        name: name,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      // In real implementation:
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception('Google sign in failed');

      return UserModel(
        id: user.uid,
        email: user.email ?? "",
        name: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  /// Sign in with Facebook
  Future<UserModel> signInWithFacebook() async {
    try {
      // In real implementation:
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        throw Exception('Facebook sign in cancelled');
      }

      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.token,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) throw Exception('Facebook sign in failed');

      return UserModel(
        id: user.uid,
        email: user.email ?? "",
        name: user.displayName ?? "",
        photoUrl: user.photoURL ?? "",
        createdAt: user.metadata.creationTime,
      );
    } catch (e) {
      throw Exception('Facebook sign in failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // In real implementation:
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user != null) {
        for (final info in user.providerData) {
          switch (info.providerId) {
            case 'google.com':
              await _googleSignIn.signOut();
              break;

            case 'facebook.com':
              await FacebookAuth.instance.logOut();
              break;
          }
        }
      }

      // Firebase signOut at last
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      // Reload user to get fresh data
      await _firebaseAuth.currentUser?.reload();

      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName,
          photoUrl: user.photoURL,
          createdAt: user.metadata.creationTime,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');

      if (name != null) {
        await user.updateDisplayName(name);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Reload to get updated data
      await user.reload();
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } catch (e) {
      String errorMessage = 'Failed to change password';

      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        errorMessage = 'Current password is incorrect';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'New password is too weak';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please log out and log in again before changing password';
      }

      throw Exception(errorMessage);
    }
  }

  /// Delete account
  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user before deletion
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Sign out from Google/Facebook if signed in via those
      for (final info in user.providerData) {
        switch (info.providerId) {
          case 'google.com':
            await _googleSignIn.signOut();
            break;
          case 'facebook.com':
            await FacebookAuth.instance.logOut();
            break;
        }
      }

      // Delete user account
      await user.delete();
    } catch (e) {
      String errorMessage = 'Failed to delete account';

      if (e.toString().contains('wrong-password') ||
          e.toString().contains('invalid-credential')) {
        errorMessage = 'Password is incorrect';
      } else if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please log out and log in again before deleting account';
      }

      throw Exception(errorMessage);
    }
  }

  /// Re-authenticate user (useful before sensitive operations)
  Future<void> reauthenticateUser(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Re-authentication failed: ${e.toString()}');
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  /// Get auth state changes stream
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}