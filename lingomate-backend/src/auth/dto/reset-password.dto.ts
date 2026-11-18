
import {
  IsString,
  MinLength,
  MaxLength,
} from 'class-validator';

export class ResetPasswordDto {
  @IsString()
  token: string;

  @IsString()
  @MinLength(8, {
    message: 'Mật khẩu phải có ít nhất 8 ký tự!',
  })
  @MaxLength(72, {
    message: 'Mật khẩu không được vượt quá 72 ký tự!',
  })
  newPassword: string;
}
