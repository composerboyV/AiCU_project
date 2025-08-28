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
      data: { 
        title: dto.title, 
        userId,
        category: dto.category || 'DAILY',
        dueDate: dto.dueDate ? new Date(dto.dueDate) : null,
      },
    });
  }

  async update(userId: number, id: number, dto: UpdateTodoDto) {
    const t = await this.prisma.todo.findFirst({ where: { id, userId } });
    if (!t) throw new NotFoundException();
    
    const updateData: any = {};
    if (dto.title !== undefined) updateData.title = dto.title;
    if (dto.done !== undefined) updateData.done = dto.done;
    if (dto.category !== undefined) updateData.category = dto.category;
    if (dto.dueDate !== undefined) updateData.dueDate = dto.dueDate ? new Date(dto.dueDate) : null;
    
    return this.prisma.todo.update({ where: { id }, data: updateData });
  }

  async remove(userId: number, id: number) {
    const t = await this.prisma.todo.findFirst({ where: { id, userId } });
    if (!t) throw new NotFoundException();
    await this.prisma.todo.delete({ where: { id } });
    return { ok: true };
  }
}
