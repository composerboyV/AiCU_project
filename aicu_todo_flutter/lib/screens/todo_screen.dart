import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'login_screen.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 Todo 목록을 가져옵니다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoListProvider.notifier).loadTodos();
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    if (_todoController.text.trim().isEmpty) return;

    try {
      await ref.read(todoListProvider.notifier).addTodo(_todoController.text.trim());
      _todoController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todo 추가 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      await ref.read(todoListProvider.notifier).updateTodo(
            todo.id,
            done: !todo.done,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todo 수정 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    try {
      await ref.read(todoListProvider.notifier).deleteTodo(todo.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todo 삭제 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final todoState = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AiCU Todo'),
            if (authState.user != null)
              Text(
                authState.user!.email,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => ref.read(todoListProvider.notifier).loadTodos(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Todo 입력 부분
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: '새로운 할 일을 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(),
          // Todo 목록 부분
          Expanded(
            child: todoState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : todoState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              '오류 발생',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(todoState.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.read(todoListProvider.notifier).loadTodos(),
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : todoState.todos.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.checklist, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  '할 일이 없습니다',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                Text(
                                  '새로운 할 일을 추가해보세요!',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: todoState.todos.length,
                            itemBuilder: (context, index) {
                              final todo = todoState.todos[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: todo.done,
                                    onChanged: (_) => _toggleTodo(todo),
                                  ),
                                  title: Text(
                                    todo.title,
                                    style: TextStyle(
                                      decoration: todo.done
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: todo.done ? Colors.grey : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '생성: ${todo.createdAt.toString().substring(0, 16)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => _deleteTodo(todo),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}