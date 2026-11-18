import 'package:flutter/material.dart';

import '../data/lesson_detail_service.dart';
import '../../progress/data/progress_service.dart';
import '../../quiz/presentation/quiz_page.dart';

class LessonDetailPage extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const LessonDetailPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  final LessonDetailService _service = LessonDetailService();
  final ProgressService _progressService = ProgressService();

  late Future<Map<String, dynamic>> _lessonFuture;

  bool _isCompleted = false;
  bool _isLoadingProgress = true;
  bool _isCompleting = false;

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF5F7FB);

  @override
  void initState() {
    super.initState();

    _lessonFuture = _service.getLessonDetail(widget.lessonId);

    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final result = await _progressService.getLessonProgress(widget.lessonId);

      if (!mounted) return;

      setState(() {
        _isCompleted = result['isCompleted'] == true;
        _isLoadingProgress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải tiến độ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeLesson() async {
    if (_isCompleting || _isCompleted) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final result = await _progressService.completeLesson(widget.lessonId);

      if (!mounted) return;

      setState(() {
        _isCompleted = result['isCompleted'] == true;
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Đã hoàn thành bài học!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể hoàn thành bài học: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _lessonFuture = _service.getLessonDetail(widget.lessonId);
    });

    await Future.wait([_lessonFuture, _loadProgress()]);
  }

  void _openQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          lessonId: widget.lessonId,
          lessonTitle: widget.lessonTitle,
        ),
      ),
    );
  }

  Widget _buildVocabulary(Map<String, dynamic> vocabulary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocabulary['word']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          if (vocabulary['pronunciation'] != null &&
              vocabulary['pronunciation'].toString().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              vocabulary['pronunciation'].toString(),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            vocabulary['meaning']?.toString() ?? 'Chưa có nghĩa',
            style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
          ),
          if (vocabulary['example'] != null &&
              vocabulary['example'].toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Ví dụ: ${vocabulary['example']}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _isCompleted ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isCompleted
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE8ECF3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.pending_actions_rounded,
                color: _isCompleted ? Colors.green : Colors.orange,
                size: 25,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isCompleted
                      ? 'Bạn đã hoàn thành bài học!'
                      : 'Bạn đã học xong bài này?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isCompleted
                        ? Colors.green.shade800
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingProgress)
            const Center(child: CircularProgressIndicator(color: primary))
          else if (_isCompleted)
            const Text(
              'Tiến độ đã được lưu thành công. Bạn có thể tiếp tục bài học tiếp theo.',
              style: TextStyle(color: Color(0xFF166534), height: 1.5),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCompleting ? null : _completeLesson,
                icon: _isCompleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isCompleting ? 'Đang lưu tiến độ...' : 'Hoàn thành bài học',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.quiz_rounded, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'KIỂM TRA KIẾN THỨC',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Thử sức với các câu hỏi để kiểm tra kiến thức vừa học nhé!',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openQuiz,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Làm bài kiểm tra',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> lesson) {
    final vocabularies = lesson['vocabularies'] is List
        ? List<Map<String, dynamic>>.from(
            (lesson['vocabularies'] as List).map(
              (item) => Map<String, dynamic>.from(item),
            ),
          )
        : <Map<String, dynamic>>[];

    final description = lesson['description']?.toString() ?? '';
    final content = lesson['content']?.toString() ?? '';

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 18),
                Text(
                  lesson['title']?.toString() ?? widget.lessonTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'NỘI DUNG BÀI HỌC',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECF3)),
            ),
            child: Text(
              content.isNotEmpty
                  ? content
                  : 'Nội dung bài học đang được cập nhật.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Color(0xFF334155),
              ),
            ),
          ),

          const SizedBox(height: 26),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'TỪ VỰNG',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '${vocabularies.length} từ',
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (vocabularies.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Bài học chưa có từ vựng.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...vocabularies.map(_buildVocabulary),

          const SizedBox(height: 22),

          _buildQuizCard(),

          const SizedBox(height: 22),

          _buildCompletionCard(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Chi tiết bài học',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _lessonFuture,
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 45,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _lessonFuture = _service.getLessonDetail(
                            widget.lessonId,
                          );
                          _loadProgress();
                        });
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu bài học.'));
          }

          return _buildContent(snapshot.data!);
        },
      ),
    );
  }
}
