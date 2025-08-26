import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findById(id: number) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  async findByEmail(emailRaw: string | undefined | null) {
    const email = (emailRaw ?? '').trim().toLowerCase();
    if (!email) return null; // 빈값이면 바로 null 반환 (Prisma 호출 X)
    return this.prisma.user.findUnique({ where: { email } });
  }

  async create(emailRaw: string, passwordHash: string) {
    const email = (emailRaw ?? '').trim().toLowerCase();
    return this.prisma.user.create({ data: { email, password: passwordHash } });
  }
}
