import 'package:flutter/material.dart';

import 'features/authentication/data/auth_service.dart';
import 'features/authentication/presentation/login_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'features/learning/presentation/learning_page.dart';
import 'features/progress/presentation/progress_page.dart';
import 'features/ai_tutor/presentation/ai_tutor_page.dart';

void main() {
  runApp(const LingoMateApp());
}

// =====================================
// APP COLORS
// =====================================

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const purple = Color(0xFF7C3AED);
  static const background = Color(0xFFF5F7FB);
  static const text = Color(0xFF172033);
  static const secondary = Color(0xFF64748B);
  static const success = Color(0xFF16A34A);
}

// =====================================
// MAIN APP
// =====================================

class LingoMateApp extends StatelessWidget {
  const LingoMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LingoMate AI',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

// =====================================
// AUTH GATE
// =====================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<Map<String, dynamic>?> _loginStatus;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loginStatus = _checkLogin();
  }

  Future<Map<String, dynamic>?> _checkLogin() async {
    return await _authService.validateToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loginStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể kết nối đến máy chủ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vui lòng kiểm tra Backend và kết nối mạng.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _loginStatus = _checkLogin();
                        });
                      },
                      child: const Text('Thử lại'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text('Đăng nhập lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return snapshot.data != null
            ? const MainNavigation()
            : const LoginPage();
      },
    );
  }
}

// =====================================
// MAIN NAVIGATION
// =====================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    LearningPage(),
    AiTutorPage(),
    ProgressPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Học tập',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI Tutor',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Tiến độ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

// =====================================
// HOME PAGE
// =====================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LINGOMATE AI',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Xin chào, bạn! 👋',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hôm nay chúng ta học gì nhỉ?',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.text,
                    size: 26,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // DAILY GOAL CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MỤC TIÊU HÔM NAY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.emoji_events_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '15 / 20 phút',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      value: 0.75,
                      minHeight: 9,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bạn đã hoàn thành 75% mục tiêu hôm nay!',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const SectionTitle(
              title: 'Khám phá học tập',
              subtitle: 'Chọn một hoạt động để bắt đầu',
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: const [
                FeatureCard(
                  title: 'Từ vựng',
                  subtitle: 'Học 10 từ mới',
                  icon: Icons.menu_book,
                  color: Color(0xFF2563EB),
                ),
                FeatureCard(
                  title: 'Ngữ pháp',
                  subtitle: 'Nắm vững cấu trúc',
                  icon: Icons.edit_note,
                  color: Color(0xFF16A34A),
                ),
                FeatureCard(
                  title: 'AI Tutor',
                  subtitle: 'Hỏi đáp cùng AI',
                  icon: Icons.smart_toy,
                  color: Color(0xFF7C3AED),
                ),
                FeatureCard(
                  title: 'Luyện nói',
                  subtitle: 'Thực hành giao tiếp',
                  icon: Icons.mic,
                  color: Color(0xFFEA580C),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const SectionTitle(
              title: 'Tiếp tục học',
              subtitle: 'Bài học được đề xuất cho bạn',
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'English at Work',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Lesson 01 · Introducing Yourself',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '15 phút học tập',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 17,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =====================================
// REUSABLE WIDGETS
// =====================================

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.secondary),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.secondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// =====================================
// PLACEHOLDER PAGES
// =====================================

// =====================================
// SIMPLE PAGE
// =====================================

class SimplePage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const SimplePage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
