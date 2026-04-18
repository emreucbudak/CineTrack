import 'package:flutter/material.dart';
import 'package:cinetrack/data/models/auth_models.dart';
import 'package:cinetrack/data/services/auth_service.dart';

enum RegisterFlowStatus { success, requiresVerification, failure }

class RegisterFlowResult {
  final RegisterFlowStatus status;
  final String? message;
  final String? error;
  final String? email;
  final String? temporaryToken;

  const RegisterFlowResult._({
    required this.status,
    this.message,
    this.error,
    this.email,
    this.temporaryToken,
  });

  const RegisterFlowResult.success({String? message})
    : this._(status: RegisterFlowStatus.success, message: message);

  const RegisterFlowResult.requiresVerification({
    required String email,
    required String temporaryToken,
    String? message,
  }) : this._(
         status: RegisterFlowStatus.requiresVerification,
         message: message,
         email: email,
         temporaryToken: temporaryToken,
       );

  const RegisterFlowResult.failure({required String error})
    : this._(status: RegisterFlowStatus.failure, error: error);
}

class RegisterCodeVerificationResult {
  final bool success;
  final String? message;
  final String? error;

  const RegisterCodeVerificationResult._({
    required this.success,
    this.message,
    this.error,
  });

  const RegisterCodeVerificationResult.success({String? message})
    : this._(success: true, message: message);

  const RegisterCodeVerificationResult.failure({required String error})
    : this._(success: false, error: error);
}

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;

  RegisterViewModel(this._authService);

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<RegisterFlowResult> register() async {
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return _failValidation('Lütfen tüm alanları doldurun.');
    }

    if (password != confirmPassword) {
      return _failValidation('Şifreler eşleşmiyor.');
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final PendingAuthResult result = await _authService.register(
        email: email,
        username: username,
        password: password,
      );

      _isLoading = false;

      if (result.isPending && result.data != null) {
        _successMessage = result.message;
        notifyListeners();
        return RegisterFlowResult.requiresVerification(
          email: result.data!.email,
          temporaryToken: result.data!.temporaryToken,
          message: result.message,
        );
      }

      if (result.success) {
        _successMessage = result.message ?? 'Hesabınız oluşturuldu.';
        notifyListeners();
        return RegisterFlowResult.success(message: _successMessage);
      }

      _errorMessage = result.error ?? 'Kayıt işlemi başarısız.';
      notifyListeners();
      return RegisterFlowResult.failure(error: _errorMessage!);
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Kayıt işlemi sırasında beklenmeyen bir hata oluştu.';
      notifyListeners();
      return const RegisterFlowResult.failure(
        error: 'Kayıt işlemi sırasında beklenmeyen bir hata oluştu.',
      );
    }
  }

  RegisterFlowResult _failValidation(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
    return RegisterFlowResult.failure(error: message);
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

class RegisterCodeVerificationViewModel extends ChangeNotifier {
  final AuthService _authService;
  final String email;
  final String temporaryToken;

  RegisterCodeVerificationViewModel(
    this._authService, {
    required this.email,
    required this.temporaryToken,
  });

  final codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<RegisterCodeVerificationResult> verifyCode() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      _errorMessage = 'Lütfen doğrulama kodunu girin.';
      _successMessage = null;
      notifyListeners();
      return const RegisterCodeVerificationResult.failure(
        error: 'Lütfen doğrulama kodunu girin.',
      );
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final MessageAuthResult result = await _authService.verifyRegisterCode(
        temporaryToken: temporaryToken,
        code: code,
      );

      _isLoading = false;

      if (result.success) {
        _successMessage = result.message ?? 'Hesabınız doğrulandı.';
        notifyListeners();
        return RegisterCodeVerificationResult.success(message: _successMessage);
      }

      _errorMessage =
          result.error ?? 'Doğrulama kodu geçersiz veya süresi dolmuş olabilir.';
      notifyListeners();
      return RegisterCodeVerificationResult.failure(error: _errorMessage!);
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Doğrulama işlemi şu anda tamamlanamadı.';
      notifyListeners();
      return const RegisterCodeVerificationResult.failure(
        error: 'Doğrulama işlemi şu anda tamamlanamadı.',
      );
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
