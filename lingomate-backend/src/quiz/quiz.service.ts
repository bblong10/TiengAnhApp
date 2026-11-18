
import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class QuizService {
  constructor(private readonly prisma: PrismaService) {}

  // Kiểm tra bài học có tồn tại và được xuất bản
  private async checkLesson(lessonId: string) {
    const lesson = await this.prisma.lesson.findFirst({
      where: {
        id: lessonId,
        course: {
          isPublished: true,
        },
      },
    });

    if (!lesson) {
      throw new NotFoundException('Không tìm thấy bài học.');
    }

    return lesson;
  }

  // Lấy câu hỏi, không trả đáp án đúng
  async getQuestions(lessonId: string) {
    await this.checkLesson(lessonId);

    const questions = await this.prisma.quizQuestion.findMany({
      where: { lessonId },
      select: {
        id: true,
        question: true,
        type: true,
        options: true,
        order: true,
      },
      orderBy: {
        order: 'asc',
      },
    });

    return {
      lessonId,
      totalQuestions: questions.length,
      questions,
    };
  }

  // Chuẩn hóa câu trả lời
  private normalizeAnswer(answer: string): string {
    return answer.trim().toLowerCase();
  }

  // Chấm điểm và lưu kết quả
  async submitQuiz(
    userId: string,
    lessonId: string,
    answers: { questionId: string; answer: string }[],
  ) {
    await this.checkLesson(lessonId);

    if (!Array.isArray(answers)) {
      throw new BadRequestException('Danh sách câu trả lời không hợp lệ.');
    }

    const questions = await this.prisma.quizQuestion.findMany({
      where: { lessonId },
      orderBy: { order: 'asc' },
    });

    if (questions.length === 0) {
      throw new BadRequestException(
        'Bài học chưa có câu hỏi luyện tập.',
      );
    }

    if (answers.length !== questions.length) {
      throw new BadRequestException(
        'Bạn cần trả lời đầy đủ tất cả câu hỏi.',
      );
    }

    const questionIds = new Set(questions.map((q) => q.id));
    const submittedIds = new Set<string>();

    for (const item of answers) {
      if (
        !item ||
        typeof item.questionId !== 'string' ||
        typeof item.answer !== 'string' ||
        !questionIds.has(item.questionId) ||
        submittedIds.has(item.questionId)
      ) {
        throw new BadRequestException(
          'Câu trả lời không hợp lệ.',
        );
      }

      submittedIds.add(item.questionId);
    }

    let correctAnswers = 0;

    const results = questions.map((question) => {
      const submitted = answers.find(
        (item) => item.questionId === question.id,
      );

      const isCorrect =
        this.normalizeAnswer(submitted!.answer) ===
        this.normalizeAnswer(question.correctAnswer);

      if (isCorrect) {
        correctAnswers++;
      }

      return {
        questionId: question.id,
        question: question.question,
        yourAnswer: submitted!.answer,
        correctAnswer: question.correctAnswer,
        isCorrect,
        explanation: question.explanation,
      };
    });

    const totalQuestions = questions.length;

    const score = Math.round(
      (correctAnswers / totalQuestions) * 100,
    );

    const attempt = await this.prisma.quizAttempt.create({
      data: {
        userId,
        lessonId,
        correctAnswers,
        totalQuestions,
        score,
      },
    });

    return {
      message: 'Nộp bài luyện tập thành công.',
      attemptId: attempt.id,
      correctAnswers,
      totalQuestions,
      score,
      results,
    };
  }

  // Lịch sử luyện tập của người dùng
  async getHistory(userId: string) {
    const attempts = await this.prisma.quizAttempt.findMany({
      where: { userId },
      include: {
        lesson: {
          select: {
            id: true,
            title: true,
            course: {
              select: {
                title: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return attempts;
  }
}
