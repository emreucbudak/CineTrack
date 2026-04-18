import 'package:flutter/material.dart';
import 'package:cinetrack/data/models/auth_models.dart';
import 'package:cinetrack/data/services/auth_service.dart';

enum LoginFlowStatus { authenticated, pendingVerification, failure }

class LoginFlowResult {
  const LoginFlowResult._({
    required this.status,
    this.email,
    this.temporaryToken,
    this.errorMessage,
  });

  const LoginFlowResult.authenticated()
    : this._(status: LoginFlowStatus.authenticated);

  const LoginFlowResult.pendingVerification({
    required String email,
    required String temporaryToken,
  }) : this._(
         status: LoginFlowStatus.pendingVerification,
         email: email,
         temporaryToken: temporaryToken,
       );

  const LoginFlowResult.failure(String message)
    : this._(status: LoginFlowStatus.failure, errorMessage: message);

  final LoginFlowStatus status;
  final String? email;
  final String? temporaryToken;
  final String? errorMessage;

  bool get isAuthenticated => status == LoginFlowStatus.authenticated;
  bool get needsVerification => status == LoginFlowStatus.pendingVerification;
}

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<LoginFlowResult> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Lütfen tüm alanları doldurun.';
      notifyListeners();
      return const LoginFlowResult.failure('Lütfen tüm alanları doldurun.');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final PendingAuthResult result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result.isPending && result.data != null) {
      notifyListeners();
      return LoginFlowResult.pendingVerification(
        email: result.data!.email,
        temporaryToken: result.data!.temporaryToken,
      );
    }

    if (result.success) {
      notifyListeners();
      return const LoginFlowResult.authenticated();
    }

    _errorMessage = result.error ?? 'Giriş başarısız.';
    notifyListeners();
    return LoginFlowResult.failure(_errorMessage!);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
