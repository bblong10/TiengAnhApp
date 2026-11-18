import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class LessonsService {
  constructor(private readonly prisma: PrismaService) {}

  async getLessonDetail(lessonId: string) {
    const lesson = await this.prisma.lesson.findUnique({
      where: {
        id: lessonId,
      },
      select: {
        id: true,
        courseId: true,
        title: true,
        description: true,
        content: true,
        order: true,
        createdAt: true,
        vocabularies: {
          select: {
            id: true,
            word: true,
            meaning: true,
            pronunciation: true,
            example: true,
            createdAt: true,
          },
          orderBy: {
            createdAt: 'asc',
          },
        },
      },
    });

    if (!lesson) {
      throw new NotFoundException('Không tìm thấy bài học.');
    }

    return {
      ...lesson,
      totalVocabulary: lesson.vocabularies.length,
    };
  }
}