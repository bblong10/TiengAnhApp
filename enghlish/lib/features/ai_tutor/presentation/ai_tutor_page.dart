import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class AiTutorPage extends StatefulWidget {
  const AiTutorPage({super.key});

  @override
  State<AiTutorPage> createState() => _AiTutorPageState();
}

class _AiTutorPageState extends State<AiTutorPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = ApiClient().dio;

  final List<Map<String, dynamic>> _messages = [];

  bool _isLoading = false;
  String? _conversationId;

  static const Color primary = Color(0xFF2563EB);
  static const Color purple = Color(0xFF7C3AED);
  static const Color background = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color secondary = Color(0xFF64748B);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'content': message, 'isUser': true});

      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _dio.post(
        '/ai-tutor/chat',
        data: {
          'message': message,
          if (_conversationId != null) 'conversationId': _conversationId,
        },
      );

      final data = response.data;

      if (data is! Map) {
        throw Exception('Dữ liệu phản hồi không hợp lệ.');
      }

      final reply =
          data['reply']?.toString() ??
          data['response']?.toString() ??
          data['message']?.toString();

      if (reply == null || reply.isEmpty) {
        throw Exception('AI chưa trả về nội dung.');
      }

      if (!mounted) return;

      setState(() {
        _conversationId = data['conversationId']?.toString() ?? _conversationId;

        _messages.add({
          'content': reply,
          'isUser': false,
          'correction': data['correction']?.toString(),
          'suggestion': data['suggestion']?.toString(),
          'translation': data['translation']?.toString(),
        });
      });
    } on DioException catch (e) {
      if (!mounted) return;

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String? serverMessage;

      if (responseData is Map) {
        final rawMessage = responseData['message'];

        if (rawMessage is List) {
          serverMessage = rawMessage.join('\n');
        } else if (rawMessage != null) {
          serverMessage = rawMessage.toString();
        }
      }

      String errorText;

      if (statusCode == 401) {
        errorText =
            'Phiên đăng nhập hết hạn hoặc thiếu Access Token. '
            'Bạn hãy đăng nhập lại nhé.';
      } else if (statusCode == 503) {
        errorText =
            serverMessage ?? 'Gemini đang quá tải. Bạn thử lại sau nhé.';
      } else if (statusCode == 400) {
        errorText = serverMessage ?? 'Nội dung gửi lên không hợp lệ.';
      } else if (statusCode == 500) {
        errorText = serverMessage ?? 'Máy chủ AI gặp lỗi nội bộ.';
      } else if (statusCode == 404) {
        errorText = 'Không tìm thấy API AI Tutor. Hãy kiểm tra Backend.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorText = 'Kết nối đến máy chủ quá thời gian chờ.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorText = 'Máy chủ phản hồi quá lâu. Bạn thử lại nhé.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorText =
            'Không thể kết nối Backend. Hãy kiểm tra máy chủ '
            'và địa chỉ API.';
      } else {
        errorText =
            serverMessage ??
            'Lỗi kết nối. Mã lỗi: '
                '${statusCode ?? "không xác định"}';
      }

      setState(() {
        _messages.add({'content': errorText, 'isUser': false, 'isError': true});
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'content': 'Đã xảy ra lỗi: $e',
          'isUser': false,
          'isError': true,
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendSuggestion(String text) {
    _messageController.text = text;
    _sendMessage();
  }

  void _clearConversation() {
    if (_isLoading) return;

    setState(() {
      _messages.clear();
      _conversationId = null;
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LingoMate AI Tutor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Trợ lý luyện tiếng Anh A1',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _clearConversation,
                tooltip: 'Cuộc hội thoại mới',
                icon: const Icon(
                  Icons.add_comment_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.white, size: 21),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Luyện giao tiếp tiếng Anh mỗi ngày. '
                    'AI sẽ giúp bạn sửa lỗi và cải thiện câu trả lời.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.forum_outlined, color: primary, size: 43),
            ),
            const SizedBox(height: 20),
            const Text(
              'Xin chào! Bạn muốn học gì hôm nay?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              'Hãy bắt đầu bằng một câu tiếng Anh đơn giản. '
              'Mình sẽ hỗ trợ bạn luyện tập.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 25),
            _buildSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      'Hello! How are you?',
      'Introduce yourself.',
      'Teach me English vocabulary.',
      'Practice English at work.',
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 10,
      children: suggestions.map((suggestion) {
        return ActionChip(
          backgroundColor: Colors.white,
          side: BorderSide(color: primary.withValues(alpha: 0.15)),
          label: Text(
            suggestion,
            style: const TextStyle(color: primary, fontSize: 12),
          ),
          onPressed: () => _sendSuggestion(suggestion),
        );
      }).toList(),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['isUser'] == true;
    final isError = message['isError'] == true;

    final content = message['content']?.toString() ?? '';

    final correction = message['correction']?.toString();
    final suggestion = message['suggestion']?.toString();
    final translation = message['translation']?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.orange.withValues(alpha: 0.1)
                    : primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isError ? Icons.info_outline : Icons.smart_toy,
                color: isError ? Colors.orange : primary,
                size: 19,
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? primary : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      color: isUser ? Colors.white : textColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (!isUser &&
                      correction != null &&
                      correction.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    _buildExtraInfo(
                      'Giải thích lỗi sai',
                      correction,
                      Icons.edit_note,
                    ),
                  ],
                  if (!isUser &&
                      translation != null &&
                      translation.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    _buildExtraInfo(
                      'Nghĩa tiếng Việt',
                      translation,
                      Icons.translate,
                    ),
                  ],
                  if (!isUser &&
                      suggestion != null &&
                      suggestion.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    _buildExtraInfo(
                      'Gợi ý cải thiện',
                      suggestion,
                      Icons.lightbulb_outline,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildExtraInfo(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(color: textColor, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16, left: 42),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: primary),
          ),
          SizedBox(width: 10),
          Text(
            'AI Tutor đang trả lời...',
            style: TextStyle(color: secondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi tiếng Anh...',
                  hintStyle: const TextStyle(color: secondary, fontSize: 13),
                  filled: true,
                  fillColor: background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                onPressed: _isLoading ? null : _sendMessage,
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingIndicator();
                      }

                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),
          _buildInput(),
        ],
      ),
    );
  }
}
