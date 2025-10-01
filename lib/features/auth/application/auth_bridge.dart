import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { passenger, driver }

class AuthState {
  final bool loggedIn;
  final UserRole? role;
  const AuthState({required this.loggedIn, this.role});
}

final authBridgeProvider =
    NotifierProvider<AuthBridgeController, AuthState>(AuthBridgeController.new);

class AuthBridgeController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(loggedIn: false, role: null);

  void selectRole(UserRole role) => state = AuthState(loggedIn: state.loggedIn, role: role);
  void loginSuccess() => state = AuthState(loggedIn: true, role: state.role);
  void logout() => state = const AuthState(loggedIn: false, role: null);
}
