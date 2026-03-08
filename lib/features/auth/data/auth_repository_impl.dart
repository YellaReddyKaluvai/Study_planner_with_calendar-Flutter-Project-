import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Web OAuth client from Firebase project, used to request ID tokens on Android.
  static const String _googleServerClientId =
      '470707781599-djtekid7qlu22d75s8nc3lj7crmqpc4j.apps.googleusercontent.com';

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: _googleServerClientId,
              scopes: const ['email', 'profile'],
            ),
        _firestore = firestore ?? FirebaseFirestore.instance;

  UserEntity _mapFirebaseUser(User? user) {
    if (user == null) {
      return UserEntity.empty();
    }
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
      lastLoginAt: user.metadata.lastSignInTime,
    );
  }

  @override
  Stream<UserEntity> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_mapFirebaseUser);

  @override
  UserEntity? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  Future<void> _syncUserToFirestore(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };

    // Use set with merge to create if not exists or update fields
    await userRef.set(userData, SetOptions(merge: true));

    // If creationTime is needed and document is new, it might be handled by a cloud function or set here if we check existence.
    // For now, simple merge is good for "creating/updating".
    final docSnap = await userRef.get();
    if (!docSnap.exists || !docSnap.data()!.containsKey('createdAt')) {
      await userRef.set(
          {'createdAt': FieldValue.serverTimestamp(), ...userData},
          SetOptions(merge: true));
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _syncUserToFirestore(credential.user!);
      }
      return _mapFirebaseUser(credential.user);
    } catch (e) {
      // Throw custom exceptions or rethrow
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password,
      {String? displayName}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await credential.user!.updateDisplayName(displayName);
          await credential.user!.reload();
        }

        // Get the updated user to sync
        final updatedUser = _firebaseAuth.currentUser;
        if (updatedUser != null) {
          await _syncUserToFirestore(updatedUser);
          return _mapFirebaseUser(updatedUser);
        }
      }
      return _mapFirebaseUser(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);

        if (userCredential.user != null) {
          await _syncUserToFirestore(userCredential.user!);
        }

        return _mapFirebaseUser(userCredential.user);
      } else {
        // Clear cached sessions to avoid stale/expired Google credentials.
        await _googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return UserEntity.empty();
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message:
                'Google Sign-In did not return an ID token. Verify Firebase Android SHA fingerprints and OAuth configuration.',
          );
        }

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);

        if (userCredential.user != null) {
          await _syncUserToFirestore(userCredential.user!);
        }

        return _mapFirebaseUser(userCredential.user);
      }
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' || e.code == '10') {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message:
              'Google Sign-In is misconfigured for this Android app (SHA-1/SHA-256 missing or outdated google-services.json).',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      if (kIsWeb) {
        // Disconnect forces the account picker on next login for web
        await _googleSignIn.disconnect();
      }
    } catch (e) {
      debugPrint('Google Sign Out Error: $e');
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
