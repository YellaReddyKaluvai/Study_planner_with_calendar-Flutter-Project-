import 'dart:io';
import '../../auth/domain/user_entity.dart';

abstract class UserRepository {
  Future<void> updateUser(UserEntity user);
  Future<String> uploadProfileImage(String uid, File imageFile);
  Stream<UserEntity> getUserStream(String uid);
}
