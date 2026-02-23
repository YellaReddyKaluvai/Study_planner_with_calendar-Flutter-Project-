import 'user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity> get authStateChanges;
  UserEntity? get currentUser;
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> signUpWithEmailAndPassword(String email, String password,
      {String? displayName});
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
