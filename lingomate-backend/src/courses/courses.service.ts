
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CoursesService {
  constructor(private readonly prisma: PrismaService) {}

  // Lấy danh sách khóa học
  async getAllCourses() {
    const courses = await this.prisma.course.findMany({
      where: {
        isPublished: true,
      },
      select: {
        id: true,
        title: true,
        description: true,
        level: true,
        category: true,
        createdAt: true,
        _count: {
          select: {
            lessons: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return courses.map((course) => ({
      id: course.id,
      title: course.title,
      description: course.description,
      level: course.level,
      category: course.category,
      createdAt: course.createdAt,
      totalLessons: course._count.lessons,
    }));
  }

  // Lấy danh sách bài học của một khóa học
  async getLessonsByCourse(courseId: string) {
    const course = await this.prisma.course.findUnique({
      where: {
        id: courseId,
      },
      select: {
        id: true,
        isPublished: true,
      },
    });

    if (!course || !course.isPublished) {
      throw new NotFoundException('Không tìm thấy khóa học.');
    }

    const lessons = await this.prisma.lesson.findMany({
      where: {
        courseId,
      },
      select: {
        id: true,
        title: true,
        description: true,
        order: true,
        createdAt: true,
        _count: {
          select: {
            vocabularies: true,
          },
        },
      },
      orderBy: {
        order: 'asc',
      },
    });

    return lessons.map((lesson) => ({
      id: lesson.id,
      title: lesson.title,
      description: lesson.description,
      order: lesson.order,
      createdAt: lesson.createdAt,
      totalVocabulary: lesson._count.vocabularies,
    }));
  }
}
