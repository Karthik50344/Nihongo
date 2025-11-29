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
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      return UserModel(
        id: userCredential.user?.uid ?? "",
        email: userCredential.user?.email ?? "",
        name: userCredential.user?.displayName,
        photoUrl: userCredential.user?.photoURL,
        createdAt: DateTime.now(),
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
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      return UserModel(
        id: userCredential.user?.uid ?? "",
        email: userCredential.user?.email ?? "",
        name: userCredential.user?.displayName ?? "",
        photoUrl: userCredential.user?.photoURL ?? "",
        createdAt: DateTime.now(),
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
      // In real implementation:
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName,
          photoUrl: user.photoURL,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}