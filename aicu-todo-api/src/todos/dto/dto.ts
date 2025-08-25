import { IsBoolean, IsString, MinLength } from 'class-validator';
export class CreateTodoDto { @IsString() @MinLength(1) title: string; }
export class UpdateTodoDto { @IsBoolean() done: boolean; }
