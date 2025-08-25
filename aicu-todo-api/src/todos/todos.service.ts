import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';

@Injectable()
export class TodosService {
  constructor(private readonly prisma: PrismaService) {}

  list(userId: number) {
    return this.prisma.todo.findMany({
      where: { userId },
      orderBy: { id: 'desc' },
    });
  }

  create(userId: number, dto: CreateTodoDto) {
    return this.prisma.todo.create({
      data: { title: dto.title, userId },
    });
  }

  async update(userId: number, id: number, dto: UpdateTodoDto) {
    const t = await this.prisma.todo.findFirst({ where: { id, userId } });
    if (!t) throw new NotFoundException();
    return this.prisma.todo.update({ where: { id }, data: dto });
  }

  async remove(userId: number, id: number) {
    const t = await this.prisma.todo.findFirst({ where: { id, userId } });
    if (!t) throw new NotFoundException();
    await this.prisma.todo.delete({ where: { id } });
    return { ok: true };
  }
}
