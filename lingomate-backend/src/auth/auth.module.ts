
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';
import { MailService } from './mail.service';

@Module({
  imports: [
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const secret = configService.get<string>('JWT_SECRET');

        if (!secret) {
          throw new Error(
            'JWT_SECRET chưa được cấu hình trong .env',
          );
        }

        return {
          secret,
          signOptions: {
            expiresIn: '1d',
          },
        };
      },
    }),
  ],

  controllers: [AuthController],

  providers: [
    AuthService,
    JwtAuthGuard,
    MailService,
  ],

  exports: [
    AuthService,
    JwtAuthGuard,
    JwtModule,
  ],
})
export class AuthModule {}
