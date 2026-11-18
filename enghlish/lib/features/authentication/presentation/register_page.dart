import 'package:flutter/material.dart';

import '../../../main.dart';
import '../data/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agree = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  // XỬ LÝ ĐĂNG KÝ
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đăng ký thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
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
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tạo tài khoản mới 🚀',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Bắt đầu hành trình chinh phục tiếng Anh cùng LingoMate AI.',
                  style: TextStyle(color: AppColors.secondary),
                ),

                const SizedBox(height: 28),

                _label('Họ và tên'),

                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isLoading,
                  decoration: _decoration(
                    'Nhập họ và tên',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ tên';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _label('Email'),

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: _decoration(
                    'example@email.com',
                    Icons.email_outlined,
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

                const SizedBox(height: 18),

                _label('Mật khẩu'),

                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration:
                      _decoration(
                        'Tối thiểu 8 ký tự',
                        Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Mật khẩu phải có ít nhất 8 ký tự';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _label('Xác nhận mật khẩu'),

                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  enabled: !_isLoading,
                  decoration: _decoration('Nhập lại mật khẩu', Icons.lock_reset)
                      .copyWith(
                        suffixIcon: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }

                    if (value != _password.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                CheckboxListTile(
                  value: _agree,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _agree = value ?? false;
                          });
                        },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Tôi đồng ý với điều khoản sử dụng và chính sách bảo mật.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            'Tạo tài khoản',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                    child: const Text('Đã có tài khoản? Đăng nhập'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    ),
  );
}

InputDecoration _decoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.secondary),
    filled: true,
    fillColor: AppColors.background,
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
