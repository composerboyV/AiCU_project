import { IsString, MinLength, IsEnum, IsOptional, IsDateString } from 'class-validator';

export enum TodoCategory {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
}

export class CreateTodoDto {
  @IsString()
  @MinLength(1)
  title!: string;
  
  @IsOptional()
  @IsEnum(TodoCategory)
  category?: TodoCategory;
  
  @IsOptional()
  @IsDateString()
  dueDate?: string;
}
