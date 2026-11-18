
import {
  BadRequestException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';

import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';

@Injectable()
export class AiTutorService {
  private readonly ai: GoogleGenAI;

  constructor(
    private readonly configService: ConfigService,
  ) {
    const apiKey = this.configService.get<string>(
      'GEMINI_API_KEY',
    );

    if (!apiKey) {
      throw new Error('Thiếu GEMINI_API_KEY trong file .env');
    }

    this.ai = new GoogleGenAI({ apiKey });
  }

  async chat(
    userId: string,
    message: string,
    conversationId?: string,
  ) {
    if (!message || !message.trim()) {
      throw new BadRequestException(
        'Vui lòng nhập nội dung tin nhắn.',
      );
    }

    const prompt = `
Bạn là LingoMate AI Tutor, giáo viên tiếng Anh thân thiện.

Đối tượng học viên:
- Người Việt Nam mới bắt đầu học tiếng Anh.
- Trình độ Beginner.
- Có thể chưa hiểu nhiều từ vựng và ngữ pháp.

Nguyên tắc trả lời:
1. Sử dụng tiếng Việt để giải thích khi cần.
2. Ưu tiên câu tiếng Anh ngắn, dễ hiểu.
3. Giải thích nghĩa tiếng Việt của câu tiếng Anh.
4. Nếu học viên viết sai, hãy sửa lỗi nhẹ nhàng.
5. Đưa ra một ví dụ thực tế.
6. Khuyến khích học viên luyện tập.
7. Không trả lời lan man.
8. Nếu học viên hỏi ngoài chủ đề tiếng Anh, vẫn hỗ trợ lịch sự.

Tin nhắn của học viên:
${message.trim()}
`;

    for (let attempt = 1; attempt <= 3; attempt++) {
      try {
        const response = await this.ai.models.generateContent({
          model: 'gemini-3.8-flash',
          contents: prompt,
        });

        const reply =
          response.text?.trim() ||
          'Mình chưa tạo được câu trả lời. Bạn thử lại nhé!';

        return {
          reply,
          conversationId:
            conversationId ?? `conversation-${userId}`,
        };
      } catch (error) {
        const status =
          typeof error === 'object' &&
          error !== null &&
          'status' in error
            ? Number(error.status)
            : 0;

        console.error(
          `AI Tutor Error - lần thử ${attempt}:`,
          error,
        );

        if (
          (status === 503 || status === 429) &&
          attempt < 3
        ) {
          await new Promise((resolve) =>
            setTimeout(resolve, attempt * 2000),
          );

          continue;
        }

        if (status === 503 || status === 429) {
          throw new ServiceUnavailableException(
            'Gemini đang quá tải. Bạn vui lòng thử lại sau ít phút.',
          );
        }

        throw new ServiceUnavailableException(
          'AI Tutor chưa thể xử lý yêu cầu. Vui lòng thử lại sau.',
        );
      }
    }
  }
}
