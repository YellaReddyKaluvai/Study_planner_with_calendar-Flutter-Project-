import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../auth/domain/user_entity.dart';
import '../domain/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> updateUser(UserEntity user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'displayName': user.displayName,
      'email':
          user.email, // Usually email is not updatable here, but just in case
      'photoUrl': user.photoUrl,
    });
  }

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('user_profiles').child('$uid.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Stream<UserEntity> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return UserEntity.empty();
      final data = snapshot.data()!;
      return UserEntity(
        uid: uid,
        email: data['email'] ?? '',
        displayName: data['displayName'],
        photoUrl: data['photoUrl'],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      );
    });
  }
}
