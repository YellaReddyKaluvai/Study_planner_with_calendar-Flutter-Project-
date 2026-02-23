import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return UserEntity.empty();
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

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
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
