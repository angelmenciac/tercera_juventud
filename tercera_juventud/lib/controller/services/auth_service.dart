import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// Sign in with Google - compatible Android/iOS and Web.
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: usar popup (recomendado)
      final provider = GoogleAuthProvider();
      try {
        final result = await _auth.signInWithPopup(provider);
        return result;
      } on FirebaseAuthException catch (e) {
        // Puede fallar si no configuras OAuth en Google Cloud / Firebase
        rethrow;
      } catch (e) {
        rethrow;
      }
    } else {
      // Mobile (Android / iOS)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      try {
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          // Usuario canceló el diálogo
          return null;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        rethrow;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    // Cerrar sesión en Firebase y también en GoogleSignIn (si aplica)
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }
}
