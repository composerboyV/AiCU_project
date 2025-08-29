import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'login_screen.dart';
import 'calendar_screen.dart';

class EnhancedTodoScreen extends ConsumerStatefulWidget {
  const EnhancedTodoScreen({super.key});

  @override
  ConsumerState<EnhancedTodoScreen> createState() => _EnhancedTodoScreenState();
}

class _EnhancedTodoScreenState extends ConsumerState<EnhancedTodoScreen> {
  final _todoController = TextEditingController();
  TodoCategory _selectedCategory = TodoCategory.DAILY;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoListProvider.notifier).loadTodos();
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: GoogleFonts.crimsonTextTextTheme(Theme.of(context).textTheme),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addTodo() async {
    final text = _todoController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('할 일을 입력해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      print('Adding todo: $text, category: $_selectedCategory, dueDate: $_selectedDate');
      await ref.read(todoListProvider.notifier).addTodo(
        text,
        category: _selectedCategory,
        dueDate: _selectedDate,
      );
      _todoController.clear();
      setState(() {
        _selectedDate = null;
        _selectedCategory = TodoCategory.DAILY;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('할 일이 추가되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding todo: $e');
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

  String _getCategoryDisplayName(TodoCategory category) {
    switch (category) {
      case TodoCategory.DAILY:
        return '매일';
      case TodoCategory.WEEKLY:
        return '주간';
      case TodoCategory.MONTHLY:
        return '월간';
    }
  }

  Color _getCategoryColor(TodoCategory category) {
    switch (category) {
      case TodoCategory.DAILY:
        return Colors.green;
      case TodoCategory.WEEKLY:
        return Colors.orange;
      case TodoCategory.MONTHLY:
        return Colors.purple;
    }
  }

  List<Todo> _getFilteredTodos(List<Todo> todos, TodoCategory category) {
    return todos.where((todo) => todo.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final todoState = ref.watch(todoListProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.crimsonTextTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                'assets/images/todo_list_icon.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.checklist, size: 32);
                },
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AiCU Todo',
                    style: GoogleFonts.crimsonText(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (authState.user != null)
                    Text(
                      authState.user!.email,
                      style: GoogleFonts.crimsonText(fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },
              icon: const Icon(Icons.calendar_month),
              tooltip: '달력 보기',
            ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _todoController,
                          style: GoogleFonts.crimsonText(),
                          decoration: InputDecoration(
                            hintText: '새로운 할 일을 입력하세요...',
                            hintStyle: GoogleFonts.crimsonText(),
                            border: const OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTodo(),
                          textInputAction: TextInputAction.done,
                          enableSuggestions: true,
                          autocorrect: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addTodo,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // 카테고리 선택
                      Expanded(
                        child: DropdownButtonFormField<TodoCategory>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: '카테고리',
                            labelStyle: GoogleFonts.crimsonText(),
                            border: const OutlineInputBorder(),
                          ),
                          items: TodoCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(category),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getCategoryDisplayName(category),
                                    style: GoogleFonts.crimsonText(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 날짜 선택
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                                : '마감일 선택',
                            style: GoogleFonts.crimsonText(),
                          ),
                        ),
                      ),
                    ],
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
                                style: GoogleFonts.crimsonText(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                todoState.error!,
                                style: GoogleFonts.crimsonText(),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.read(todoListProvider.notifier).loadTodos(),
                                child: Text(
                                  '다시 시도',
                                  style: GoogleFonts.crimsonText(),
                                ),
                              ),
                            ],
                          ),
                        )
                      : DefaultTabController(
                          length: 4,
                          child: Column(
                            children: [
                              TabBar(
                                labelStyle: GoogleFonts.crimsonText(fontWeight: FontWeight.bold),
                                unselectedLabelStyle: GoogleFonts.crimsonText(),
                                isScrollable: true,
                                tabs: const [
                                  Tab(text: '전체'),
                                  Tab(text: '매일'),
                                  Tab(text: '주간'),
                                  Tab(text: '월간'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildTodoList(todoState.todos), // 전체
                                    _buildTodoList(_getFilteredTodos(todoState.todos, TodoCategory.DAILY)),
                                    _buildTodoList(_getFilteredTodos(todoState.todos, TodoCategory.WEEKLY)),
                                    _buildTodoList(_getFilteredTodos(todoState.todos, TodoCategory.MONTHLY)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.checklist, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '할 일이 없습니다',
              style: GoogleFonts.crimsonText(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            Text(
              '새로운 할 일을 추가해보세요!',
              style: GoogleFonts.crimsonText(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(todo.category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: todo.done,
                  onChanged: (_) => _toggleTodo(todo),
                ),
              ],
            ),
            title: Text(
              todo.title,
              style: GoogleFonts.crimsonText(
                decoration: todo.done ? TextDecoration.lineThrough : TextDecoration.none,
                color: todo.done ? Colors.grey : null,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '생성: ${todo.createdAt.toString().substring(0, 16)}',
                  style: GoogleFonts.crimsonText(fontSize: 12, color: Colors.grey),
                ),
                if (todo.dueDate != null)
                  Text(
                    '마감: ${todo.dueDate!.toString().substring(0, 10)}',
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: todo.dueDate!.isBefore(DateTime.now()) ? Colors.red : Colors.blue,
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              onPressed: () => _deleteTodo(todo),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}