
import {
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly resend: Resend;

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.get<string>('RESEND_API_KEY');

    if (!apiKey) {
      throw new Error('Thiếu cấu hình RESEND_API_KEY trong file .env');
    }

    this.resend = new Resend(apiKey);
  }

  async sendPasswordResetEmail(
    email: string,
    resetUrl: string,
  ): Promise<void> {
    const from =
      this.configService.get<string>('MAIL_FROM');

    if (!from) {
      throw new Error('Thiếu cấu hình MAIL_FROM trong file .env');
    }

    try {
      const { data, error } = await this.resend.emails.send({
        from,
        to: [email],
        subject: 'Khôi phục mật khẩu LingoMate AI',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 560px; margin: auto;">
            <h2>Khôi phục mật khẩu</h2>
            <p>Bạn vừa yêu cầu đặt lại mật khẩu tài khoản LingoMate AI.</p>
            <p>Nhấn nút bên dưới để tạo mật khẩu mới:</p>
            <a href="${resetUrl}"
              style="display:inline-block;padding:12px 20px;background:#2563eb;color:white;text-decoration:none;border-radius:8px;">
              Đặt lại mật khẩu
            </a>
            <p>Liên kết có hiệu lực trong 15 phút và chỉ sử dụng được một lần.</p>
            <p>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email.</p>
          </div>
        `,
      });

      if (error) {
        this.logger.error(`Resend error: ${error.message}`);
        throw new InternalServerErrorException(
          'Không thể gửi email khôi phục mật khẩu.',
        );
      }

      if (!data?.id) {
        throw new InternalServerErrorException(
          'Resend không xác nhận email đã được gửi.',
        );
      }
    } catch (error) {
      this.logger.error('Gửi email khôi phục thất bại.');

      if (error instanceof InternalServerErrorException) {
        throw error;
      }

      throw new InternalServerErrorException(
        'Không thể gửi email khôi phục mật khẩu.',
      );
    }
  }
}
