
import { Controller, Get, Param } from '@nestjs/common';
import { CoursesService } from './courses.service';

@Controller('courses')
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  // GET /courses
  @Get()
  async getAllCourses() {
    return this.coursesService.getAllCourses();
  }

  // GET /courses/:courseId/lessons
  @Get(':courseId/lessons')
  async getLessonsByCourse(@Param('courseId') courseId: string) {
    return this.coursesService.getLessonsByCourse(courseId);
  }
}
