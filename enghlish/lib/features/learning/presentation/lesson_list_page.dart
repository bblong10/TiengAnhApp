import 'package:flutter/material.dart';

import '../data/lesson_service.dart';
import 'lesson_detail_page.dart';

class LessonListPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const LessonListPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<LessonListPage> createState() => _LessonListPageState();
}

class _LessonListPageState extends State<LessonListPage> {
  final LessonService _lessonService = LessonService();

  late Future<List<Map<String, dynamic>>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() {
    _lessonsFuture = _lessonService.getLessons(widget.courseId);
  }

  void _retry() {
    setState(() {
      _loadLessons();
    });
  }

  void _openLesson(Map<String, dynamic> lesson) {
    final lessonId = lesson['id']?.toString() ?? '';
    final lessonTitle = lesson['title']?.toString() ?? 'Bài học';

    if (lessonId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy mã bài học.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LessonDetailPage(lessonId: lessonId, lessonTitle: lessonTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          widget.courseTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildMessage(
              icon: Icons.error_outline,
              message: 'Không thể tải bài học.',
              detail: snapshot.error.toString(),
              action: 'Thử lại',
            );
          }

          final lessons = snapshot.data ?? [];

          if (lessons.isEmpty) {
            return _buildMessage(
              icon: Icons.menu_book_outlined,
              message: 'Khóa học chưa có bài học.',
              detail: 'Các bài học sẽ được cập nhật sớm.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _retry();
              await _lessonsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Danh sách bài học',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${lessons.length} bài học trong khóa học này',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),

                ...lessons.map((lesson) {
                  final order = lesson['order'] ?? 1;
                  final title = lesson['title'] ?? 'Bài học';
                  final description = lesson['description'] ?? 'Chưa có mô tả';
                  final totalVocabulary = lesson['totalVocabulary'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: Text(
                          '$order',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      title: Text(
                        title.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(description.toString()),
                            const SizedBox(height: 5),
                            Text(
                              '$totalVocabulary từ vựng',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF64748B),
                      ),
                      onTap: () => _openLesson(lesson),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String message,
    required String detail,
    String? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF64748B)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _retry, child: Text(action)),
            ],
          ],
        ),
      ),
    );
  }
}
