import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../authentication/data/auth_service.dart';
import '../../authentication/presentation/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  late Future<Map<String, dynamic>?> _profileFuture;

  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    return await _authService.validateToken();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _loadProfile();
    });

    await _profileFuture;
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đăng xuất. Vui lòng thử lại.')),
      );

      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Chưa có thông tin';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Chưa có thông tin';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> data) {
    final userData = data['user'];

    if (userData is! Map) {
      return const Center(child: Text('Dữ liệu tài khoản không hợp lệ.'));
    }

    final user = Map<String, dynamic>.from(userData);

    final fullName = user['fullName']?.toString() ?? 'Người dùng';
    final email = user['email']?.toString() ?? 'Chưa có email';
    final createdAt = _formatDate(user['createdAt']);

    final initial = fullName.trim().isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : 'U';

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'HỒ SƠ CỦA TÔI',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Thành viên LingoMate AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Thông tin tài khoản',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            icon: Icons.person_outline,
            title: 'Họ và tên',
            value: fullName,
          ),

          _buildInfoCard(
            icon: Icons.email_outlined,
            title: 'Địa chỉ email',
            value: email,
          ),

          _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'Ngày tạo tài khoản',
            value: createdAt,
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _isLoggingOut ? null : _logout,
              icon: _isLoggingOut
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(_isLoggingOut ? 'Đang đăng xuất...' : 'Đăng xuất'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 50,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể tải thông tin tài khoản.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _refreshProfile,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Phiên đăng nhập đã hết hạn.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _logout,
                    child: const Text('Quay lại đăng nhập'),
                  ),
                ],
              ),
            );
          }

          return _buildProfileContent(snapshot.data!);
        },
      ),
    );
  }
}
