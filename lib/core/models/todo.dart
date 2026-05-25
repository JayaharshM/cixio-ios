class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool completed;
  final DateTime createdAt;
  final bool isPinned;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'completed': completed,
        'created_at': createdAt.toIso8601String(),
        'is_pinned': isPinned,
      };
}
