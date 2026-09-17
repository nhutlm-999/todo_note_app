class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool isPinned;
  final int colorValue; // 0 là màu card mặc định
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel ({
    required this.id,
    required this.title,
    this.content = '',
    this.isPinned = false,
    this.colorValue = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    int? colorValue,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      colorValue: colorValue ?? this.colorValue,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isPinned': isPinned,
      'colorValue': colorValue,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String, 
      title: json['title'] as String,
      content: (json['content'] as String?) ?? '',
      isPinned: (json['isPinned'] as bool?) ?? false,
      colorValue: (json['colorValue'] as int?) ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((tag) => tag.toString()).toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)     
          : DateTime.now(), 
    );
  }
}