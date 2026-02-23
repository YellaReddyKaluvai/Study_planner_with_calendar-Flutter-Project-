import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../profile/data/user_repository_impl.dart';
import '../../profile/domain/user_repository.dart';
import '../../auth/domain/user_entity.dart'; // Fixed import path
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

final userProfileStreamProvider = StreamProvider.autoDispose<UserEntity>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null || currentUser.uid.isEmpty) {
    return Stream.value(UserEntity.empty());
  }

  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStream(currentUser.uid);
});

class ProfileState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const ProfileState(
      {this.isLoading = false, this.error, this.isSuccess = false});

  ProfileState copyWith({bool? isLoading, String? error, bool? isSuccess}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserRepository _userRepository;
  final Ref _ref;

  ProfileNotifier(this._userRepository, this._ref)
      : super(const ProfileState());

  Future<void> updateDisplayName(String newName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(displayName: newName);
        await _userRepository.updateUser(updatedUser);
        state = state.copyWith(isLoading: false, isSuccess: true);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadImage(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentUser = _ref.read(currentUserProvider);
      if (currentUser != null) {
        final downloadUrl = await _userRepository.uploadProfileImage(
            currentUser.uid, imageFile);
        final updatedUser = currentUser.copyWith(photoUrl: downloadUrl);
        await _userRepository.updateUser(updatedUser);
        state = state.copyWith(isLoading: false, isSuccess: true);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return ProfileNotifier(userRepository, ref);
});
