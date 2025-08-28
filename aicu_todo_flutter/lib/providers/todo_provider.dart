import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

// Todo 목록 상태
final todoListProvider = StateNotifierProvider<TodoListNotifier, TodoListState>((ref) {
  return TodoListNotifier();
});

class TodoListState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodoListState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });

  TodoListState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodoListState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TodoListNotifier extends StateNotifier<TodoListState> {
  TodoListNotifier() : super(TodoListState());

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final todos = await ApiService.getTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addTodo(String title, {TodoCategory? category, DateTime? dueDate}) async {
    try {
      final newTodo = await ApiService.createTodo(title, category: category, dueDate: dueDate);
      state = state.copyWith(
        todos: [...state.todos, newTodo],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateTodo(int id, {String? title, bool? done, TodoCategory? category, DateTime? dueDate}) async {
    try {
      final updatedTodo = await ApiService.updateTodo(id, title: title, done: done, category: category, dueDate: dueDate);
      final updatedTodos = state.todos.map((todo) {
        return todo.id == id ? updatedTodo : todo;
      }).toList();
      
      state = state.copyWith(todos: updatedTodos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await ApiService.deleteTodo(id);
      final updatedTodos = state.todos.where((todo) => todo.id != id).toList();
      state = state.copyWith(todos: updatedTodos);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}