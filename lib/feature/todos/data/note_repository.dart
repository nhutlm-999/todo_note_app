import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_note_app/feature/todos/domain/models/note_model.dart';

class NoteRepository {
  static const String _storageKey = 'notes_data_v1';

  // Nạp danh sách ghi chú từ máy
  Future<List<NoteModel>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return _getSampleNotes(); // Trả về ghi chú mẫu nếu mới mở app lần đầu
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((item) => NoteModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // Lưu danh sách ghi chú xuống máy
  Future<void> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  // Dữ liệu mẫu ban đầu
  List<NoteModel> _getSampleNotes() {
    final now = DateTime.now();
    return [
      NoteModel(
        id: '1',
        title: '💡 Ý tưởng phát triển ứng dụng',
        content: '1. Thêm đồng bộ đám mây (Firebase)\n2. Hỗ trợ thông báo hẹn giờ\n3. Thống kê năng suất làm việc.',
        isPinned: true,
        colorValue: 0xFFFFF9C4, // Vàng pastel
        tags: ['Ý tưởng', 'Flutter'],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}