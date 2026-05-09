import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/geometric_pattern.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscure = true;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match', style: AppTheme.body(color: Colors.white)),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _apiService.register(_name.text, _email.text, _password.text);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}', style: AppTheme.body(color: Colors.white)),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space6, AppTheme.space7, AppTheme.space6, AppTheme.space7),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create your account', style: AppTheme.h1()),
                    const SizedBox(height: AppTheme.space2),
                    Text('Join the community in seeking knowledge', style: AppTheme.body()),
                    const SizedBox(height: AppTheme.space7),
                    _SimpleField(controller: _name, label: 'Full name', hint: 'e.g. Aisha Rahman', icon: Icons.person_outline_rounded),
                    const SizedBox(height: AppTheme.space4),
                    _SimpleField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@example.com',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.space4),
                    _SimpleField(
                      controller: _password,
                      label: 'Password',
                      hint: 'At least 6 characters',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppTheme.textGrey, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.space4),
                    _SimpleField(
                      controller: _confirm,
                      label: 'Confirm password',
                      hint: 'Repeat password',
                      icon: Icons.lock_reset_rounded,
                      obscure: _obscure,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Please confirm your password' : null,
                    ),
                    const SizedBox(height: AppTheme.space7),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Create account'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space7),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: AppTheme.body()),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            ),
                            child: Text(
                              'Sign in',
                              style: AppTheme.body(color: AppTheme.primaryGreen).copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientHero,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(48), bottomRight: Radius.circular(48)),
            child: const Positioned.fill(child: GeometricPattern(opacity: 0.07, cell: 56)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space4),
              child: Row(
                children: [
                  Material(
                    color: Colors.white.withOpacity(0.14),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Text('Sign up', style: AppTheme.h2(color: Colors.white)),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppTheme.space6,
            right: AppTheme.space6,
            bottom: AppTheme.space5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Begin your journey', style: AppTheme.display(color: Colors.white).copyWith(fontSize: 28)),
                const SizedBox(height: 4),
                Text('Knowledge is the lamp of the heart',
                    style: AppTheme.body(color: Colors.white.withOpacity(0.86)).copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _SimpleField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption(color: AppTheme.textDark).copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
          style: AppTheme.body(color: AppTheme.textDark),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
