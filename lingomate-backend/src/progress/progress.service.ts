
import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProgressService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // LẤY TỔNG QUAN TIẾN ĐỘ HỌC
  async getOverview(userId: string) {
    const [totalLessons, completedLessons, progress] =
      await Promise.all([
        this.prisma.lesson.count({
          where: {
            course: {
              isPublished: true,
            },
          },
        }),

        this.prisma.learningProgress.count({
          where: {
            userId,
            isCompleted: true,
            lesson: {
              course: {
                isPublished: true,
              },
            },
          },
        }),

        this.prisma.learningProgress.findMany({
          where: {
            userId,
            isCompleted: true,
            lesson: {
              course: {
                isPublished: true,
              },
            },
          },
          include: {
            lesson: {
              include: {
                course: {
                  select: {
                    id: true,
                    title: true,
                  },
                },
              },
            },
          },
          orderBy: {
            completedAt: 'desc',
          },
        }),
      ]);

    const percentage =
      totalLessons > 0
        ? Math.round(
            (completedLessons / totalLessons) * 100,
          )
        : 0;

    return {
      totalLessons,
      completedLessons,
      remainingLessons: totalLessons - completedLessons,
      percentage,
      completed: progress.map((item) => ({
        lessonId: item.lessonId,
        lessonTitle: item.lesson.title,
        courseId: item.lesson.course.id,
        courseTitle: item.lesson.course.title,
        completedAt: item.completedAt,
      })),
    };
  }

  // KIỂM TRA TIẾN ĐỘ MỘT BÀI HỌC
  async getLessonProgress(
    userId: string,
    lessonId: string,
  ) {
    const lesson = await this.prisma.lesson.findUnique({
      where: {
        id: lessonId,
      },
      select: {
        id: true,
        title: true,
      },
    });

    if (!lesson) {
      throw new NotFoundException(
        'Không tìm thấy bài học!',
      );
    }

    const progress =
      await this.prisma.learningProgress.findUnique({
        where: {
          userId_lessonId: {
            userId,
            lessonId,
          },
        },
      });

    return {
      lessonId,
      lessonTitle: lesson.title,
      isCompleted: progress?.isCompleted ?? false,
      completedAt: progress?.completedAt ?? null,
    };
  }

  // ĐÁNH DẤU HOÀN THÀNH BÀI HỌC
  async completeLesson(
    userId: string,
    lessonId: string,
  ) {
    const lesson = await this.prisma.lesson.findUnique({
      where: {
        id: lessonId,
      },
      select: {
        id: true,
        title: true,
        course: {
          select: {
            isPublished: true,
          },
        },
      },
    });

    if (!lesson || !lesson.course.isPublished) {
      throw new NotFoundException(
        'Không tìm thấy bài học!',
      );
    }

    const progress =
      await this.prisma.learningProgress.upsert({
        where: {
          userId_lessonId: {
            userId,
            lessonId,
          },
        },
        create: {
          userId,
          lessonId,
          isCompleted: true,
          completedAt: new Date(),
        },
        update: {
          isCompleted: true,
          completedAt: new Date(),
        },
      });

    return {
      message: 'Đã hoàn thành bài học!',
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      isCompleted: progress.isCompleted,
      completedAt: progress.completedAt,
    };
  }
}

