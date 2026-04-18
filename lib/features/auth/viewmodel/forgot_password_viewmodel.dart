import 'package:cinetrack/data/models/auth_models.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:flutter/material.dart';

enum ForgotPasswordFlowStatus { pendingVerification, success, failure }

class ForgotPasswordFlowResult {
  const ForgotPasswordFlowResult._({
    required this.status,
    required this.email,
    this.temporaryToken,
    this.message,
  });

  const ForgotPasswordFlowResult.pendingVerification({
    required String email,
    required String temporaryToken,
    String? message,
  }) : this._(
         status: ForgotPasswordFlowStatus.pendingVerification,
         email: email,
         temporaryToken: temporaryToken,
         message: message,
       );

  const ForgotPasswordFlowResult.success({
    required String email,
    String? message,
  }) : this._(
         status: ForgotPasswordFlowStatus.success,
         email: email,
         message: message,
       );

  const ForgotPasswordFlowResult.failure(String message)
    : this._(
        status: ForgotPasswordFlowStatus.failure,
        email: '',
        message: message,
      );

  final ForgotPasswordFlowStatus status;
  final String email;
  final String? temporaryToken;
  final String? message;

  bool get needsVerification =>
      status == ForgotPasswordFlowStatus.pendingVerification;
  bool get isSuccess => status == ForgotPasswordFlowStatus.success;
  bool get isFailure => status == ForgotPasswordFlowStatus.failure;
}

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<ForgotPasswordFlowResult> requestPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      const message = 'Lütfen e-posta adresinizi girin.';
      _errorMessage = message;
      notifyListeners();
      return const ForgotPasswordFlowResult.failure(message);
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final PendingAuthResult result = await _authService.requestPasswordReset(
        email: email,
      );

      _isLoading = false;

      if (result.isPending && result.data != null) {
        notifyListeners();
        return ForgotPasswordFlowResult.pendingVerification(
          email: result.data!.email,
          temporaryToken: result.data!.temporaryToken,
          message: result.message,
        );
      }

      if (result.success) {
        notifyListeners();
        return ForgotPasswordFlowResult.success(
          email: email,
          message: result.message,
        );
      }

      _errorMessage = result.error ?? 'Şifre yenileme isteği başarısız.';
      notifyListeners();
      return ForgotPasswordFlowResult.failure(_errorMessage!);
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Şifre yenileme servisi şu anda kullanılamıyor.';
      notifyListeners();
      return const ForgotPasswordFlowResult.failure(
        'Şifre yenileme servisi şu anda kullanılamıyor.',
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
