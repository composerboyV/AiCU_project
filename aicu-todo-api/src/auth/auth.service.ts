import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService, private jwt: JwtService) {}

  async register(emailRaw: string, password: string) {
    const email = (emailRaw ?? '').trim().toLowerCase();
    if (!email || !password) throw new UnauthorizedException('Invalid input');

    const exist = await this.prisma.user.findUnique({ where: { email } });
    if (exist) throw new ConflictException('Email already registered');

    const hash = await bcrypt.hash(password, 10);
    const user = await this.prisma.user.create({ data: { email, password: hash } });

    return this.issue(user.id, user.email);
  }

  async login(emailRaw: string, password: string) {
    const email = (emailRaw ?? '').trim().toLowerCase();
    if (!email || !password) throw new UnauthorizedException('Invalid credentials');

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) throw new UnauthorizedException('Invalid credentials');

    return this.issue(user.id, user.email);
  }

  private issue(id: number, email: string) {
    const payload = { sub: id, email };
    const access_token = this.jwt.sign(payload, {
      secret: process.env.JWT_SECRET || 'devsecret',
      expiresIn: process.env.JWT_EXPIRES || '1d',
    });
    return { access_token };
  }
}
