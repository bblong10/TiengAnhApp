import 'package:flutter/material.dart';

import '../data/course_service.dart';
import 'lesson_list_page.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final CourseService _courseService = CourseService();

  late Future<List<Map<String, dynamic>>> _coursesFuture;

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color secondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _coursesFuture = _courseService.getCourses();
  }

  void _loadCourses() {
    setState(() {
      _coursesFuture = _courseService.getCourses();
    });
  }

  Future<void> _openCourse(Map<String, dynamic> course) async {
    final courseId = course['id']?.toString();
    final courseTitle = course['title']?.toString() ?? 'Khóa học';

    if (courseId == null || courseId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy mã khóa học.')),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LessonListPage(courseId: courseId, courseTitle: courseTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Khóa học của bạn',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh, color: primary),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final future = _courseService.getCourses();

            setState(() {
              _coursesFuture = future;
            });

            await future;
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _coursesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primary),
                );
              }

              if (snapshot.hasError) {
                return _buildError();
              }

              final courses = snapshot.data ?? [];

              if (courses.isEmpty) {
                return _buildEmpty();
              }

              return _buildCourseList(courses);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList(List<Map<String, dynamic>> courses) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Bắt đầu hành trình tiếng Anh của bạn!',
          style: TextStyle(fontSize: 14, color: secondary),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.menu_book, color: primary),
            const SizedBox(width: 8),
            Text(
              '${courses.length} khóa học khả dụng',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...courses.map(_buildCourseCard),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final title = course['title']?.toString() ?? 'Khóa học';
    final description = course['description']?.toString() ?? 'Chưa có mô tả';
    final category = course['category']?.toString() ?? 'Chưa phân loại';
    final level = course['level']?.toString() ?? 'A1';
    final lessons = course['totalLessons'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openCourse(course),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: secondary),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: secondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(category, primary),
                    _buildTag('Trình độ $level', Colors.deepPurple),
                    _buildTag('$lessons bài học', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        const Icon(Icons.wifi_off, size: 55, color: secondary),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Không thể tải khóa học',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Hãy kiểm tra kết nối Backend.',
            style: TextStyle(color: secondary),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.menu_book_outlined, size: 60, color: secondary),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Chưa có khóa học nào',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
