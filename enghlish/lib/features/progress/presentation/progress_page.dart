import 'package:flutter/material.dart';

import '../data/progress_service.dart';
import '../../quiz/data/quiz_service.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final ProgressService _progressService = ProgressService();
  final QuizService _quizService = QuizService();

  late Future<Map<String, dynamic>> _progressFuture;
  late Future<dynamic> _historyFuture;

  static const Color primary = Color(0xFF2563EB);
  static const Color purple = Color(0xFF7C3AED);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color secondary = Color(0xFF64748B);
  static const Color success = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _progressFuture = _progressService.getOverview();
    _historyFuture = _quizService.getHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });

    try {
      await Future.wait([_progressFuture, _historyFuture]);
    } catch (_) {
      // FutureBuilder sẽ hiển thị thông báo lỗi.
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<Map<String, dynamic>> _getCompletedList(Map<String, dynamic> data) {
    final rawList =
        data['completed'] ??
        data['completedItems'] ??
        data['completedLessonsList'] ??
        data['items'];

    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<Map<String, dynamic>> _getHistoryList(dynamic value) {
    dynamic rawList = value;

    if (value is Map) {
      rawList =
          value['history'] ??
          value['attempts'] ??
          value['items'] ??
          value['data'];
    }

    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _getLessonTitle(Map<String, dynamic> item) {
    final lesson = item['lesson'];

    if (lesson is Map) {
      return lesson['title']?.toString() ??
          lesson['lessonTitle']?.toString() ??
          'Bài học';
    }

    return item['lessonTitle']?.toString() ??
        item['title']?.toString() ??
        'Bài học';
  }

  String _getCourseTitle(Map<String, dynamic> item) {
    final lesson = item['lesson'];

    if (lesson is Map) {
      final course = lesson['course'];

      if (course is Map) {
        return course['title']?.toString() ?? 'Khóa học';
      }

      return lesson['courseTitle']?.toString() ?? 'Khóa học';
    }

    return item['courseTitle']?.toString() ?? 'Khóa học';
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Chưa có ngày ghi nhận';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Chưa có ngày ghi nhận';

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return success;
    if (score >= 50) return const Color(0xFFEA580C);
    return const Color(0xFFDC2626);
  }

  Widget _buildHistorySection() {
    return FutureBuilder<dynamic>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: primary)),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Icon(Icons.wifi_off, size: 35, color: secondary),
                const SizedBox(height: 10),
                const Text(
                  'Không thể tải lịch sử kiểm tra.',
                  style: TextStyle(color: secondary),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _historyFuture = _quizService.getHistory();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final historyList = _getHistoryList(snapshot.data);

        if (historyList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(Icons.assignment_outlined, size: 45, color: secondary),
                SizedBox(height: 12),
                Text(
                  'Chưa có lịch sử kiểm tra.',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Hãy hoàn thành một bài kiểm tra để xem kết quả tại đây nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondary, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return Column(
          children: historyList.map((item) {
            final score = _toInt(item['score']);
            final correct = _toInt(item['correctAnswers']);
            final total = _toInt(item['totalQuestions']);
            final createdAt = item['createdAt'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getScoreColor(score).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.assignment_turned_in,
                      color: _getScoreColor(score),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLessonTitle(item),
                          style: const TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _getCourseTitle(item),
                          style: const TextStyle(
                            color: secondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Đúng $correct/$total câu',
                          style: const TextStyle(
                            color: secondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngày làm: ${_formatDate(createdAt)}',
                          style: const TextStyle(
                            color: secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        '$score%',
                        style: TextStyle(
                          color: _getScoreColor(score),
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Điểm số',
                        style: TextStyle(color: secondary, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tiến độ học tập',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh, color: primary),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, size: 55, color: secondary),
                    const SizedBox(height: 16),
                    const Text(
                      'Không thể tải tiến độ học tập.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: secondary),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Chưa có dữ liệu tiến độ.'));
          }

          final data = snapshot.data!;

          final totalLessons = _toInt(data['totalLessons']);
          final completedLessons = _toInt(data['completedLessons']);
          final remainingLessons = _toInt(data['remainingLessons']);

          final rawPercentage = _toDouble(data['percentage']);

          final percentage = rawPercentage > 1
              ? rawPercentage / 100
              : rawPercentage;

          final safePercentage = percentage.clamp(0.0, 1.0);
          final completedList = _getCompletedList(data);

          return RefreshIndicator(
            onRefresh: _refresh,
            color: primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // OVERVIEW CARD
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primary, purple],
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
                            'TỔNG QUAN HỌC TẬP',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Icon(
                            Icons.emoji_events_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        '${(safePercentage * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tiến độ hoàn thành khóa học',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: safePercentage,
                          minHeight: 10,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Đã hoàn thành $completedLessons / $totalLessons bài học',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // STATISTICS
                const Text(
                  'THỐNG KÊ HỌC TẬP',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book,
                        title: 'Tổng bài học',
                        value: totalLessons.toString(),
                        color: primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle,
                        title: 'Đã hoàn thành',
                        value: completedLessons.toString(),
                        color: success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pending_actions,
                        title: 'Còn lại',
                        value: remainingLessons.toString(),
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // COMPLETED LESSONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BÀI HỌC ĐÃ HOÀN THÀNH',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${completedList.length} bài',
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (completedList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 45,
                          color: secondary,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có bài học hoàn thành.',
                          style: TextStyle(color: secondary),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Hãy tiếp tục học để ghi nhận tiến độ nhé!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...completedList.map((item) {
                    final completedAt =
                        item['completedAt'] ?? item['updatedAt'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
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
                              color: success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: success,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getLessonTitle(item),
                                  style: const TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _getCourseTitle(item),
                                  style: const TextStyle(
                                    color: secondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatDate(completedAt),
                                  style: const TextStyle(
                                    color: success,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 28),

                // QUIZ HISTORY
                const Row(
                  children: [
                    Icon(Icons.history, color: primary, size: 21),
                    SizedBox(width: 8),
                    Text(
                      'LỊCH SỬ KIỂM TRA',
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildHistorySection(),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
