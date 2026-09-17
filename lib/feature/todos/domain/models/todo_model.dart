class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String priority;
  final String category;

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    this.priority = 'medium',
    this.category = 'cá nhân',
  });

  // Tạo bản sao mới với những thuộc tính được ghi đè
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
    String? category,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Chuyển đối tượng sang Map để chuẩn bị lưu thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'priority': priority,
      'category': category,
    };
  }


  /// [factory] là một constructor đặc biệt không nhất thiết phải luôn tạo mới một instance của class (có thể trả về instance cũ hoặc instance của class con).
  /// [.fromJson] là một "named constructor" (constructor có tên). Đây là quy ước đặt tên trong Dart/Flutter để tạo đối tượng từ dữ liệu JSON, không phải là cú pháp bắt buộc của ngôn ngữ.
  /// [as String] là toán tử ép kiểu (type casting), dùng để khẳng định với compiler rằng giá trị lấy ra từ Map (kiểu dynamic) chắc chắn là kiểu String. Đây không phải là alias.
  
  // Tạo đối tượng từ dữ liệu JSON đọc lên từ đĩa
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      priority: (json['priority'] as String?) ?? 'medium',
      category: (json['category'] as String?) ?? 'Cá nhân',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
