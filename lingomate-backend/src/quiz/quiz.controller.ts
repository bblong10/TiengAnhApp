
import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import { QuizService } from './quiz.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('quiz')
@UseGuards(JwtAuthGuard)
export class QuizController {
  constructor(private readonly quizService: QuizService) {}

  // Lấy danh sách câu hỏi của bài học
  @Get('lessons/:lessonId/questions')
  getQuestions(
    @Param('lessonId') lessonId: string,
  ) {
    return this.quizService.getQuestions(lessonId);
  }

  // Nộp bài và lưu kết quả
  @Post('lessons/:lessonId/submit')
  submitQuiz(
    @Param('lessonId') lessonId: string,
    @Body() body: { answers: { questionId: string; answer: string }[] },
    @Req() req: any,
  ) {
    return this.quizService.submitQuiz(
      req.user.sub,
      lessonId,
      body.answers,
    );
  }

  // Xem lịch sử luyện tập
  @Get('history')
  getHistory(@Req() req: any) {
    return this.quizService.getHistory(req.user.sub);
  }
}
