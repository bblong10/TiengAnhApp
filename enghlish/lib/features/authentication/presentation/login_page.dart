import 'package:flutter/material.dart';

import '../../../main.dart';
import '../data/auth_service.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // XỬ LÝ ĐĂNG NHẬP
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đăng nhập thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.purple],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Center(
                      child: Text(
                        'LINGOMATE AI',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    const Text(
                      'Chào mừng trở lại! 👋',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Đăng nhập để tiếp tục hành trình học tiếng Anh.',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 9),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập email';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                          return 'Email không hợp lệ';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Mật khẩu',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 9),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration:
                          _inputDecoration(
                            hint: 'Nhập mật khẩu',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }

                        if (value.length < 8) {
                          return 'Mật khẩu tối thiểu 8 ký tự';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.6,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Chưa có tài khoản?',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// INPUT DECORATION
InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.secondary),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
