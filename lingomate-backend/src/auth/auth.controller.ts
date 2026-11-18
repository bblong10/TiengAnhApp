
import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import type { Request } from 'express';

import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { JwtAuthGuard } from './jwt-auth.guard';

type AuthenticatedRequest = Request & {
  user: {
    sub: string;
    email: string;
  };
};

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  // ĐĂNG KÝ
  @Post('register')
  async register(
    @Body() registerDto: RegisterDto,
  ) {
    return this.authService.register(registerDto);
  }

  // ĐĂNG NHẬP
  @Post('login')
  async login(
    @Body() loginDto: LoginDto,
  ) {
    return this.authService.login(loginDto);
  }

  // QUÊN MẬT KHẨU
  @Post('forgot-password')
  async forgotPassword(
    @Body() dto: ForgotPasswordDto,
  ) {
    return this.authService.forgotPassword(dto);
  }

  // ĐẶT LẠI MẬT KHẨU
  @Post('reset-password')
  async resetPassword(
    @Body() dto: ResetPasswordDto,
  ) {
    return this.authService.resetPassword(dto);
  }

  // KIỂM TRA TÀI KHOẢN ĐANG ĐĂNG NHẬP
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getMe(
    @Req() request: AuthenticatedRequest,
  ) {
    return this.authService.getProfile(
      request.user.sub,
    );
  }
}
