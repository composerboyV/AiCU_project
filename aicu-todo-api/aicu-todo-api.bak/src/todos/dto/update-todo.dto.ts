import { IsBoolean, IsOptional, IsString, MinLength, IsEnum, IsDateString } from 'class-validator';
import { TodoCategory } from './create-todo.dto';

export class UpdateTodoDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  title?: string;

  @IsOptional()
  @IsBoolean()
  done?: boolean;
  
  @IsOptional()
  @IsEnum(TodoCategory)
  category?: TodoCategory;
  
  @IsOptional()
  @IsDateString()
  dueDate?: string;
}
