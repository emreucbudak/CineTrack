import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinetrack/core/theme/app_colors.dart';
import 'package:cinetrack/data/services/auth_service.dart';
import 'package:cinetrack/features/auth/viewmodel/register_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final RegisterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel(context.read<AuthService>());
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
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
    if (_viewModel.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.successMessage!),
          backgroundColor: Colors.green.shade700,
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

  Future<void> _handleRegister() async {
    final success = await _viewModel.register();
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 40),
                    _buildForm(),
                    const SizedBox(height: 32),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildSocialButtons(),
                    const SizedBox(height: 32),
                    _buildLoginLink(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
              padding: EdgeInsets.zero,
            ),
          ),
          Row(
            children: [
              Icon(Icons.movie, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              const Text(
                'CineTrack',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hesap Oluştur',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sinema tutkunları için hazırlanan topluluğa katılın.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'E-POSTA ADRESİ',
          hint: 'name@example.com',
          icon: Icons.mail_outline,
          controller: _viewModel.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'KULLANICI ADI',
          hint: 'Bir kullanıcı adı seçin',
          icon: Icons.person_outline,
          controller: _viewModel.usernameController,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'ŞİFRE',
          hint: 'Bir şifre oluşturun',
          icon: Icons.lock_outline,
          controller: _viewModel.passwordController,
          isPassword: true,
          obscure: _viewModel.obscurePassword,
          onToggleVisibility: _viewModel.togglePasswordVisibility,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: 'ŞİFRE TEKRARI',
          hint: 'Şifrenizi tekrar girin',
          icon: Icons.shield_outlined,
          controller: _viewModel.confirmPasswordController,
          isPassword: true,
          obscure: _viewModel.obscureConfirmPassword,
          onToggleVisibility: _viewModel.toggleConfirmPasswordVisibility,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _viewModel.isLoading ? null : _handleRegister,
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
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && obscure,
          style: const TextStyle(color: AppColors.textLight, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.primary.withValues(alpha: 0.05),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(icon, color: AppColors.textMuted, size: 22),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.1))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Veya şununla kaydolun',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ),
        Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textLight,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.apple, size: 22),
            label: const Text('Apple'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textLight,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Zaten hesabınız var mı? ',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Giriş Yap',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home_outlined, false),
          _buildNavItem(Icons.movie_outlined, false),
          _buildNavItem(Icons.confirmation_number_outlined, false),
          _buildNavItem(Icons.person, true),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return IconButton(
      onPressed: () {},
      icon: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textMuted,
        size: 28,
      ),
    );
  }
}
