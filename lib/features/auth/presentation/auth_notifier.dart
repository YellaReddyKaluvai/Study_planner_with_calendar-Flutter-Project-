import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
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

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      // Success state is handled by the stream, but we stop loading
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
