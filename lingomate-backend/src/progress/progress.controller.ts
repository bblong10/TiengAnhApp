
import {
  Controller,
  Get,
  Post,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { ProgressService } from './progress.service';

type AuthenticatedRequest = Request & {
  user: {
    sub: string;
    email: string;
  };
};

@Controller('progress')
@UseGuards(JwtAuthGuard)
export class ProgressController {
  constructor(
    private readonly progressService: ProgressService,
  ) {}

  // LẤY TỔNG QUAN TIẾN ĐỘ
  @Get()
  async getOverview(
    @Req() request: AuthenticatedRequest,
  ) {
    return this.progressService.getOverview(
      request.user.sub,
    );
  }

  // KIỂM TRA TIẾN ĐỘ BÀI HỌC
  @Get('lessons/:lessonId')
  async getLessonProgress(
    @Req() request: AuthenticatedRequest,
    @Param('lessonId') lessonId: string,
  ) {
    return this.progressService.getLessonProgress(
      request.user.sub,
      lessonId,
    );
  }

  // ĐÁNH DẤU HOÀN THÀNH BÀI HỌC
  @Post('lessons/:lessonId/complete')
  async completeLesson(
    @Req() request: AuthenticatedRequest,
    @Param('lessonId') lessonId: string,
  ) {
    return this.progressService.completeLesson(
      request.user.sub,
      lessonId,
    );
  }
}
