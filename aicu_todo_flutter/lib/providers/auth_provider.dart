import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// 인증 상태
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        final user = await ApiService.getProfile();
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // 토큰이 만료되었거나 유효하지 않은 경우
      await ApiService.logout();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('로그인 시도: $email');
      await ApiService.login(email, password);
      final user = await ApiService.getProfile();
      print('로그인 성공: ${user.email}');
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      print('로그인 실패: $e');
      state = state.copyWith(
        error: e is Exception ? e.toString() : '알 수 없는 오류 발생',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('회원가입 시도: $email');
      await ApiService.register(email, password);
      final user = await ApiService.getProfile();
      print('회원가입 성공: ${user.email}');
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      print('회원가입 실패: $e');
      state = state.copyWith(
        error: e is Exception ? e.toString() : '알 수 없는 오류 발생',
        isLoading: false,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    state = AuthState();
  }
}