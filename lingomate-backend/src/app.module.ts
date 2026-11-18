
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { ResetPasswordController } from './reset-password.controller';
import { CoursesModule } from './courses/courses.module';
import { LessonsModule } from './lessons/lessons.module';
import { ProgressModule } from './progress/progress.module';
import { QuizModule } from './quiz/quiz.module';
import { AiTutorModule } from './ai-tutor/ai-tutor.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    LessonsModule,
    CoursesModule,
    ProgressModule,
    PrismaModule,
    AuthModule,
    QuizModule,
    AiTutorModule,
  ],
  controllers: [ResetPasswordController],
})
export class AppModule {}
