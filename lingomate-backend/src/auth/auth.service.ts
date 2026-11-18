
import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { randomBytes, createHash } from 'crypto';

import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { MailService } from './mail.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
  ) {}

  // =====================================
  // ĐĂNG KÝ TÀI KHOẢN
  // =====================================
  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();

    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('Email đã được sử dụng!');
    }

    const passwordHash = await argon2.hash(dto.password);

    const user = await this.prisma.user.create({
      data: {
        fullName: dto.fullName.trim(),
        email,
        passwordHash,
      },
      select: {
        id: true,
        fullName: true,
        email: true,
        createdAt: true,
      },
    });

    return {
      message: 'Đăng ký tài khoản thành công!',
      user,
    };
  }

  // =====================================
  // ĐĂNG NHẬP
  // =====================================
  async login(dto: LoginDto) {
    const email = dto.email.trim().toLowerCase();

    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new UnauthorizedException(
        'Email hoặc mật khẩu không chính xác!',
      );
    }

    const isPasswordValid = await argon2.verify(
      user.passwordHash,
      dto.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException(
        'Email hoặc mật khẩu không chính xác!',
      );
    }

    const payload = {
      sub: user.id,
      email: user.email,
    };

    const accessToken =
      await this.jwtService.signAsync(payload);

    return {
      message: 'Đăng nhập thành công!',
      accessToken,
      tokenType: 'Bearer',
      expiresIn: '1d',
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
      },
    };
  }

  // =====================================
  // QUÊN MẬT KHẨU
  // =====================================
  async forgotPassword(dto: ForgotPasswordDto) {
    const email = dto.email.trim().toLowerCase();

    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    // Không tiết lộ email có tồn tại hay không.
    const response = {
      message:
        'Nếu email tồn tại, hướng dẫn khôi phục mật khẩu sẽ được gửi.',
    };

    if (!user) {
      return response;
    }

    // Vô hiệu hóa các token cũ.
    await this.prisma.passwordResetToken.deleteMany({
      where: { userId: user.id },
    });

    // Tạo token ngẫu nhiên 256 bit.
    const rawToken = randomBytes(32).toString('hex');

    // Chỉ lưu SHA-256 hash vào database.
    const tokenHash = createHash('sha256')
      .update(rawToken)
      .digest('hex');

    const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

    await this.prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt,
      },
    });

    const frontendUrl =
      process.env.FRONTEND_URL || 'http://localhost:3000';

    const resetUrl =
      `${frontendUrl}/reset-password?token=${rawToken}`;

    try {
      await this.mailService.sendPasswordResetEmail(
        user.email,
        resetUrl,
      );
    } catch (error) {
      // Xóa token nếu gửi email thất bại.
      await this.prisma.passwordResetToken.deleteMany({
        where: { tokenHash },
      });

      throw error;
    }

    return response;
  }

  // =====================================
  // ĐẶT LẠI MẬT KHẨU
  // =====================================
  async resetPassword(dto: ResetPasswordDto) {
    const tokenHash = createHash('sha256')
      .update(dto.token)
      .digest('hex');

    const resetToken =
      await this.prisma.passwordResetToken.findUnique({
        where: { tokenHash },
      });

    if (
      !resetToken ||
      resetToken.usedAt ||
      resetToken.expiresAt.getTime() < Date.now()
    ) {
      throw new BadRequestException(
        'Liên kết khôi phục không hợp lệ hoặc đã hết hạn!',
      );
    }

    const passwordHash = await argon2.hash(
      dto.newPassword,
    );

    // Cập nhật mật khẩu và đánh dấu token đã sử dụng
    // trong cùng một transaction.
    await this.prisma.$transaction(async (tx) => {
      const result = await tx.passwordResetToken.updateMany({
        where: {
          id: resetToken.id,
          usedAt: null,
          expiresAt: { gt: new Date() },
        },
        data: {
          usedAt: new Date(),
        },
      });

      if (result.count !== 1) {
        throw new BadRequestException(
          'Liên kết khôi phục không hợp lệ hoặc đã hết hạn!',
        );
      }

      await tx.user.update({
        where: { id: resetToken.userId },
        data: { passwordHash },
      });

      // Xóa các token khôi phục còn lại của tài khoản.
      await tx.passwordResetToken.deleteMany({
        where: {
          userId: resetToken.userId,
          id: { not: resetToken.id },
        },
      });
    });

    return {
      message: 'Đặt lại mật khẩu thành công!',
    };
  }

  // =====================================
  // LẤY THÔNG TIN NGƯỜI DÙNG
  // =====================================
  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        email: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException(
        'Tài khoản không còn tồn tại!',
      );
    }

    return {
      message: 'Xác thực tài khoản thành công!',
      user,
    };
  }
}
