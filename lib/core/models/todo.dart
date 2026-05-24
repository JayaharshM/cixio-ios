class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime? dueDate;
  final bool completed;
  final DateTime createdAt;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'due_date': dueDate?.toIso8601String(),
        'completed': completed,
        'created_at': createdAt.toIso8601String(),
      };
}
