
import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';
import { join } from 'path';

@Controller()
export class ResetPasswordController {
  @Get('reset-password')
  showResetPasswordPage(@Res() res: Response) {
    return res.sendFile(
      join(process.cwd(), 'src', 'public', 'reset-password.html'),
    );
  }
}
