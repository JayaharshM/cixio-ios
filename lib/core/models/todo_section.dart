class TodoSection {
  const TodoSection({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final bool isPinned;

  factory TodoSection.fromJson(Map<String, dynamic> json) {
    return TodoSection(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'is_pinned': isPinned,
      };
}
