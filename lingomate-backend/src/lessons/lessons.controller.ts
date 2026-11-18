import { Controller, Get, Param } from '@nestjs/common';
import { LessonsService } from './lessons.service';

@Controller('lessons')
export class LessonsController {
  constructor(private readonly lessonsService: LessonsService) {}

  @Get(':lessonId')
  getLessonDetail(@Param('lessonId') lessonId: string) {
    return this.lessonsService.getLessonDetail(lessonId);
  }
}