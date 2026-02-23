import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign In with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateUserData(result.user);
      return result.user;
    } catch (e) {
      debugPrint("Error signing in with email: $e");
      rethrow;
    }
  }

  // Sign Up with Email & Password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateUserData(result.user);
      return result.user;
    } catch (e) {
      debugPrint("Error signing up with email: $e");
      rethrow;
    }
  }

  // Sign In with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);
      await _updateUserData(result.user);
      return result.user;
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // Save User Data to Firestore
  Future<void> _updateUserData(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? '',
      'photoURL': user.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    };

    // Use set with merge: true to avoid overwriting existing fields if we add more later
    await userRef.set(userData, SetOptions(merge: true));
  }
}
