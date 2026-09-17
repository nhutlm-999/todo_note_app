import 'dart:convert';
import 'package:todo_note_app/feature/todos/domain/models/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoRepository {
  static const String _storageKey = 'todos_data_v1';

  // Nạp danh sách từ bộ nhớ máy
  Future<List<TodoModel>> loadTodos() async {
    // Giả lập việc nạp dữ liệu từ bộ nhớ máy
    // Thực tế, bạn có thể sử dụng SharedPreferences, Hive, hoặc bất kỳ cơ chế lưu trữ nào khác
    // Ví dụ: SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? jsonString = prefs.getString(_storageKey);
    // Sau đó parse jsonString thành List<TodoModel>

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return _getSampleTodos();
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  } 

  // Ghi danh sách xuống bộ nhớ máy
  Future<void> saveTodos(List<TodoModel> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  // Dữ liệu mẫu giúp người mới dễ hình dung khi vừa mở app
  List<TodoModel> _getSampleTodos() {
    final now = DateTime.now();
    return [
      TodoModel(
        id: '1',
        title: 'Chào mừng bạn đến với Todo & Note!',
        description: 'Vuốt sang trái để xóa, bấm để chỉnh sửa hoặc hoàn thành.',
        isCompleted: false,
        dueDate: now.add(const Duration(hours: 3)),
        priority: 'high',
        category: 'Công việc',
        createdAt: now,
      ),
    ];
  }
}