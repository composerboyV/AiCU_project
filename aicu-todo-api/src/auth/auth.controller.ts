import { Body, Controller, Get, Post, Res, UseGuards, Req } from '@nestjs/common';
import type { Response, Request } from 'express';
import { AuthService } from './auth.service';
import { AuthGuard } from '@nestjs/passport';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

const COOKIE_NAME = 'access_token';
const cookieOpts = {
  httpOnly: true,
  sameSite: 'lax' as const,
  // secure: true, // HTTPS에서만 사용. 개발(HTTP)에서는 주석 유지
  maxAge: 1000 * 60 * 60 * 24, // 1d
  path: '/',
};

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private auth: AuthService) {}

  @Post('register')
  async register(@Body() dto: RegisterDto, @Res({ passthrough: true }) res: Response) {
    const { access_token } = await this.auth.register(dto.email, dto.password);
    res.cookie(COOKIE_NAME, access_token, cookieOpts);
    return { access_token };
  }

  @Post('login')
  async login(@Body() dto: LoginDto, @Res({ passthrough: true }) res: Response) {
    const { access_token } = await this.auth.login(dto.email, dto.password);
    res.cookie(COOKIE_NAME, access_token, cookieOpts);
    return { access_token };
  }

  @Post('logout')
  async logout(@Res({ passthrough: true }) res: Response) {
    res.clearCookie(COOKIE_NAME, { path: '/' });
    return { ok: true };
  }

  @ApiBearerAuth()
  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  me(@Req() req: Request & { user: any }) {
    return { id: req.user.userId, email: req.user.email };
  }
}
