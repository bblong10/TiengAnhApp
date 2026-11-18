import 'package:flutter/material.dart';
import '../data/quiz_service.dart';

class QuizPage extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const QuizPage({
    super.key,
    required this.lessonId,
    this.lessonTitle = 'Kiểm tra kiến thức',
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizService _quizService = QuizService();

  List<Map<String, dynamic>> _questions = [];
  final Map<String, String> _answers = {};

  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isFinished = false;

  Map<String, dynamic>? _result;
  String? _error;

  static const Color primaryColor = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions = await _quizService.getQuestions(widget.lessonId);

      if (!mounted) return;

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      if (questions.isEmpty) {
        setState(() {
          _error = 'Bài học chưa có câu hỏi kiểm tra.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _questionId(Map<String, dynamic> question) {
    return question['id']?.toString() ?? '';
  }

  String _questionType(Map<String, dynamic> question) {
    return question['type']?.toString() ?? 'MULTIPLE_CHOICE';
  }

  List<String> _options(Map<String, dynamic> question) {
    final options = question['options'];

    if (options is List) {
      return options.map((e) => e.toString()).toList();
    }

    return [];
  }

  void _selectAnswer(String answer) {
    final question = _questions[_currentIndex];

    setState(() {
      _answers[_questionId(question)] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần trả lời tất cả câu hỏi trước khi nộp bài.'),
        ),
      );
      return;
    }

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nộp bài kiểm tra?'),
        content: const Text(
          'Bạn đã hoàn thành tất cả câu hỏi. '
          'Hãy kiểm tra lại trước khi nộp nhé!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Làm tiếp'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true || !mounted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answers = _questions.map((question) {
        return {
          'questionId': _questionId(question),
          'answer': _answers[_questionId(question)] ?? '',
        };
      }).toList();

      final result = await _quizService.submitQuiz(widget.lessonId, answers);

      if (!mounted) return;

      setState(() {
        _result = result;
        _isFinished = true;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _retryQuiz() {
    setState(() {
      _answers.clear();
      _currentIndex = 0;
      _isFinished = false;
      _result = null;
    });
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error ?? 'Đã xảy ra lỗi.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentIndex];
    final questionId = _questionId(question);
    final type = _questionType(question);
    final options = _options(question);
    final selectedAnswer = _answers[questionId];

    final isFillBlank = type == 'FILL_BLANK';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu ${_currentIndex + 1}/${_questions.length}',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            minHeight: 9,
            backgroundColor: const Color(0xFFE5E7EB),
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'CÂU HỎI',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          question['question']?.toString() ?? '',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172033),
          ),
        ),
        const SizedBox(height: 28),

        if (isFillBlank)
          TextField(
            key: ValueKey(questionId),
            controller: TextEditingController(text: selectedAnswer ?? ''),
            onChanged: _selectAnswer,
            decoration: InputDecoration(
              hintText: 'Nhập câu trả lời của bạn...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          )
        else
          ...options.map((option) {
            final isSelected = selectedAnswer == option;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _selectAnswer(option),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? primaryColor : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildResult() {
    final score = _result?['score'] ?? 0;
    final correct = _result?['correctAnswers'] ?? 0;
    final total = _result?['totalQuestions'] ?? _questions.length;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 90,
              color: Color(0xFFF59E0B),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hoàn thành bài kiểm tra!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$score%',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const Text('Điểm số của bạn', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resultStat('Đúng', '$correct', Colors.green),
                  _resultStat('Tổng câu', '$total', primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _retryQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Làm lại bài kiểm tra',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại bài học'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _isFinished
          ? _buildResult()
          : _questions.isEmpty
          ? _buildError()
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestion(),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        if (_currentIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousQuestion,
                              child: const Text('Quay lại'),
                            ),
                          ),
                        if (_currentIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : _currentIndex == _questions.length - 1
                                ? _submitQuiz
                                : _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _currentIndex == _questions.length - 1
                                        ? 'Nộp bài'
                                        : 'Câu tiếp theo',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
