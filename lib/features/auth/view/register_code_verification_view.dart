import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/features/auth/view/login_view.dart';
import 'package:cinetrack/features/auth/viewmodel/register_viewmodel.dart';

class RegisterCodeVerificationView extends StatefulWidget {
  final String email;
  final String temporaryToken;

  const RegisterCodeVerificationView({
    super.key,
    required this.email,
    required this.temporaryToken,
  });

  @override
  State<RegisterCodeVerificationView> createState() =>
      _RegisterCodeVerificationViewState();
}

class _RegisterCodeVerificationViewState
    extends State<RegisterCodeVerificationView> {
  late final RegisterCodeVerificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterCodeVerificationViewModel(
      context.read<AuthService>(),
      email: widget.email,
      temporaryToken: widget.temporaryToken,
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.red.shade700,
        ),
      );
      _viewModel.clearMessages();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final result = await _viewModel.verifyCode();
    if (!mounted || !result.success) {
      return;
    }

    final message =
        result.message ??
        _viewModel.successMessage ??
        'Hesabınız doğrulandı. Şimdi giriş yapabilirsiniz.';
    _viewModel.clearMessages();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A0E0E),
          title: const Text(
            'Doğrulama Başarılı',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey.shade300),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Giriş Ekranına Dön'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120808),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildVerificationCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCrybqyVay85mnj_tSdq0p6o5JgHwOg_tHy_kMOBYKzcwyS1w1g0EU0DDpNqiKGohWY342rncBIBHjhAbAxX2HoSujKcn6AJX6DJNU7ijab5aGc5U_WkZJyUUb7t47uZF0Eu3y_zjwAFD1ZPacWIYVXNsGIJbWMIZOXjQ-wvDxLLStET_4nODJhp8ZFjomZZOXvKWRi98pIAJop72KqwFtElsDhalaKCeCdvCbdRNMZygPwCF009dZPyKcgIFxA67lqDTF2AHLyEMg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF120808).withValues(alpha: 0.8),
                  const Color(0xFF120808).withValues(alpha: 0.6),
                  const Color(0xFF120808).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF120808).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildInfo(),
          const SizedBox(height: 28),
          _buildCodeInput(),
          const SizedBox(height: 24),
          _buildVerifyButton(),
          const SizedBox(height: 24),
          _buildBackActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: AppColors.primary,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Kod Doğrulama',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      children: [
        Text(
          'Kayıt işlemini tamamlamak için ${widget.email} adresine gönderilen kodu girin.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              const Icon(Icons.mail_outline, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Doğrulama Kodu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        TextField(
          controller: _viewModel.codeController,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleVerify(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '123456',
            hintStyle: TextStyle(color: Colors.grey.shade600, letterSpacing: 4),
            filled: true,
            fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.password_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade800.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey.shade800.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _viewModel.isLoading ? null : _handleVerify,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
        ),
        child: _viewModel.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Kodu Doğrula',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildBackActions() {
    return Column(
      children: [
        Text(
          'Kodu görmüyor musun? Spam klasörünü kontrol edip tekrar dene.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Kayıt ekranına geri dön',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
