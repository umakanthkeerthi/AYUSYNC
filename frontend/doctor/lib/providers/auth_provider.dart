import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String? doctorId;
  final String? doctorName;
  final bool isAuthenticated;

  AuthState({
    this.doctorId,
    this.doctorName,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    String? doctorId,
    String? doctorName,
    bool? isAuthenticated,
  }) {
    return AuthState(
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void login(String doctorId, String doctorName) {
    state = state.copyWith(
      doctorId: doctorId,
      doctorName: doctorName,
      isAuthenticated: true,
    );
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
