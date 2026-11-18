
import {
  Body,
  Controller,
  Post,
  UseGuards,
  Request,
} from '@nestjs/common';

import { Request as ExpressRequest } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AiTutorService } from './ai-tutor.service';

interface AuthenticatedRequest extends ExpressRequest {
  user: {
    sub: string;
  };
}

@Controller('ai-tutor')
@UseGuards(JwtAuthGuard)
export class AiTutorController {
  constructor(
    private readonly aiTutorService: AiTutorService,
  ) {}

  @Post('chat')
  async chat(
    @Request() req: AuthenticatedRequest,
    @Body()
    body: {
      message: string;
      conversationId?: string;
    },
  ) {
    return this.aiTutorService.chat(
      req.user.sub,
      body.message,
      body.conversationId,
    );
  }
}
