import 'package:flutter/material.dart';

import '../../../main.dart';
import '../data/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.forgotPassword(email: _emailController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nếu email tồn tại, hướng dẫn khôi phục sẽ được gửi đến bạn.',
          ),
          backgroundColor: Colors.green,
        ),
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
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: 55,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Nhập địa chỉ email đã đăng ký. '
                  'Chúng tôi sẽ hỗ trợ bạn khôi phục tài khoản.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.secondary,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Địa chỉ email',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 10),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'example@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())) {
                      return 'Vui lòng nhập email hợp lệ';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendRequest,
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
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Gửi yêu cầu khôi phục',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton.icon(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại đăng nhập'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
