import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  String _friendlyAuthError(Object error, {required bool isGoogle}) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
          if (isGoogle) {
            return 'Google sign-in failed due to Firebase Android configuration. Add SHA-1/SHA-256 in Firebase and update google-services.json.';
          }
          return 'Invalid email or password. Please check your credentials and try again.';
        case 'user-not-found':
          return 'No account found for this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled in Firebase Authentication.';
      }
    }

    final message = error.toString();
    if (message.contains('sign_in_failed') ||
        message.contains('DEVELOPER_ERROR') ||
        message.contains('10:')) {
      return 'Google sign-in is misconfigured for Android. Ensure SHA fingerprints are added in Firebase and download a fresh google-services.json.';
    }

    return message;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      // Success state is handled by the stream, but we stop loading
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: _friendlyAuthError(e, isGoogle: false));
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password,
      {String? displayName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password,
          displayName: displayName);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: _friendlyAuthError(e, isGoogle: false));
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: _friendlyAuthError(e, isGoogle: true));
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
