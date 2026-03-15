class Message {
  const Message({
    this.id,
    required this.content,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String content;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message copyWith({
    int? id,
    String? content,
    String? imagePath,
    bool clearImagePath = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'content': content,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static Message fromMap(Map<String, Object?> map) {
    return Message(
      id: map['id'] as int?,
      content: map['content'] as String? ?? '',
      imagePath: map['image_path'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
