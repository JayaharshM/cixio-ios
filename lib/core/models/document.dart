class Document {
  const Document({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      name: json['name'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String).toLocal(),
    );
  }

  final String id;
  final String name;
  final int size;
  final String type;
  final DateTime uploadedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'size': size,
      'type': type,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
