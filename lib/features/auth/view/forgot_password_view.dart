import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/features/auth/view/forgot_password_code_verification_view.dart';
import 'package:cinetrack/features/auth/viewmodel/forgot_password_viewmodel.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  static const String _backgroundImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCrybqyVay85mnj_tSdq0p6o5JgHwOg_tHy_kMOBYKzcwyS1w1g0EU0DDpNqiKGohWY342rncBIBHjhAbAxX2HoSujKcn6AJX6DJNU7ijab5aGc5U_WkZJyUUb7t47uZF0Eu3y_zjwAFD1ZPacWIYVXNsGIJbWMIZOXjQ-wvDxLLStET_4nODJhp8ZFjomZZOXvKWRi98pIAJop72KqwFtElsDhalaKCeCdvCbdRNMZygPwCF009dZPyKcgIFxA67lqDTF2AHLyEMg';

  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel(context.read<AuthService>());
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
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
      _viewModel.clearError();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final result = await _viewModel.requestPasswordReset();
    if (!mounted) {
      return;
    }

    if (result.needsVerification) {
      if (result.message != null && result.message!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message!),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }

      if (result.temporaryToken == null) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotPasswordCodeVerificationView(
            email: result.email,
            temporaryToken: result.temporaryToken!,
          ),
        ),
      );
      return;
    }

    if (result.isSuccess) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'Şifreniz yenilendi. Giriş ekranına dönebilirsiniz.',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context);
    }
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
                child: _buildCard(),
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
            _backgroundImageUrl,
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

  Widget _buildCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Geri dön'),
          ),
          const SizedBox(height: 24),
          _buildHeader(),
          const SizedBox(height: 32),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            color: AppColors.primary,
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Şifremi Unuttum',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'E-posta adresinizi ve yeni şifrenizi girin. Uygunsa size bir doğrulama kodu göndereceğiz.',
          style: TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildInputField(
          label: 'E-posta Adresi',
          hint: 'name@example.com',
          icon: Icons.mail_outline,
          controller: _viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildPasswordField(
          label: 'Yeni Şifre',
          hint: 'Yeni şifrenizi girin',
          controller: _viewModel.newPasswordController,
          obscureText: _viewModel.obscureNewPassword,
          onToggleVisibility: _viewModel.toggleNewPasswordVisibility,
        ),
        const SizedBox(height: 24),
        _buildPasswordField(
          label: 'Şifre Tekrarı',
          hint: 'Yeni şifrenizi tekrar girin',
          controller: _viewModel.confirmPasswordController,
          obscureText: _viewModel.obscureConfirmPassword,
          onToggleVisibility: _viewModel.toggleConfirmPasswordVisibility,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _viewModel.isLoading ? null : _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                    'Doğrulama Kodunu Gönder',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
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

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.lock_outline,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
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
}
