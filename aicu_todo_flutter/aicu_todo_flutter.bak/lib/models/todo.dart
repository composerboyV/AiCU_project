enum TodoCategory {
  DAILY,
  WEEKLY,
  MONTHLY,
}

class Todo {
  final int id;
  final String title;
  final bool done;
  final int userId;
  final TodoCategory category;
  final DateTime? dueDate;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    required this.done,
    required this.userId,
    required this.category,
    this.dueDate,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
      userId: json['userId'],
      category: TodoCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TodoCategory.DAILY,
      ),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'done': done,
      'userId': userId,
      'category': category.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Todo copyWith({
    int? id,
    String? title,
    bool? done,
    int? userId,
    TodoCategory? category,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}