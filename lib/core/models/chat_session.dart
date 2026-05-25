class ChatSession {
  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isPinned = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final bool isPinned;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }
}
