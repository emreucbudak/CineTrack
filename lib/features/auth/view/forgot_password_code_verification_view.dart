import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/data/models/auth_models.dart';
import 'package:cinetrack/data/services/auth_service.dart';

class ForgotPasswordCodeVerificationView extends StatefulWidget {
  const ForgotPasswordCodeVerificationView({
    super.key,
    required this.email,
    required this.temporaryToken,
  });

  final String email;
  final String temporaryToken;

  @override
  State<ForgotPasswordCodeVerificationView> createState() =>
      _ForgotPasswordCodeVerificationViewState();
}

class _ForgotPasswordCodeVerificationViewState
    extends State<ForgotPasswordCodeVerificationView> {
  static const String _backgroundImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCrybqyVay85mnj_tSdq0p6o5JgHwOg_tHy_kMOBYKzcwyS1w1g0EU0DDpNqiKGohWY342rncBIBHjhAbAxX2HoSujKcn6AJX6DJNU7ijab5aGc5U_WkZJyUUb7t47uZF0Eu3y_zjwAFD1ZPacWIYVXNsGIJbWMIZOXjQ-wvDxLLStET_4nODJhp8ZFjomZZOXvKWRi98pIAJop72KqwFtElsDhalaKCeCdvCbdRNMZygPwCF009dZPyKcgIFxA67lqDTF2AHLyEMg';

  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showSnackBar('Lütfen 6 haneli doğrulama kodunu girin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final MessageAuthResult result = await context.read<AuthService>()
          .verifyPasswordResetCode(
            temporaryToken: widget.temporaryToken,
            code: code,
          );

      if (!mounted) {
        return;
      }

      if (result.success) {
        await _showSuccessDialog(
          result.message ??
              'Şifreniz başarıyla yenilendi. Giriş ekranına dönebilirsiniz.',
        );
        return;
      }

      _showSnackBar(result.error ?? 'Kod doğrulanamadı.');
    } catch (_) {
      if (mounted) {
        _showSnackBar('Kod doğrulama servisi şu anda kullanılamıyor.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Şifre yenilendi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey.shade300, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Giriş ekranına dön'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
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
                child: _buildVerificationCard(context),
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

  Widget _buildVerificationCard(BuildContext context) {
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
          _buildCodeField(),
          const SizedBox(height: 16),
          Text(
            'Doğrulama kodunu ${widget.email} adresine gönderdik.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: _isLoading
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
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
            Icons.mark_email_read_outlined,
            color: AppColors.primary,
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Kodu Doğrula',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Şifre yenileme işlemini tamamlamak için 6 haneli kodu girin.',
          style: TextStyle(fontSize: 15, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Doğrulama Kodu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onSubmitted: (_) {
            if (!_isLoading) {
              _handleVerify();
            }
          },
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 10,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              letterSpacing: 10,
            ),
            filled: true,
            fillColor: const Color(0xFF0F172A).withValues(alpha: 0.5),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.password_rounded,
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
}
