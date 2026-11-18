
import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { JwtService } from '@nestjs/jwt';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
  ) {}

  async canActivate(
    context: ExecutionContext,
  ): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    const authorization = request.headers.authorization;

    if (!authorization || !authorization.startsWith('Bearer ')) {
      throw new UnauthorizedException(
        'Bạn chưa đăng nhập hoặc thiếu Access Token!',
      );
    }

    const token = authorization.substring(7);

    try {
      const payload = await this.jwtService.verifyAsync(token);

      if (!payload.sub) {
        throw new UnauthorizedException(
          'Access Token không hợp lệ!',
        );
      }

      request.user = payload;

      return true;
    } catch {
      throw new UnauthorizedException(
        'Phiên đăng nhập đã hết hạn hoặc không hợp lệ!',
      );
    }
  }
}
