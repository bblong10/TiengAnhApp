
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AiTutorController } from './ai-tutor.controller';
import { AiTutorService } from './ai-tutor.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [ConfigModule, AuthModule],
  controllers: [AiTutorController],
  providers: [AiTutorService],
})
export class AiTutorModule {}
