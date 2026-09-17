import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/todos/data/note_repository.dart';
import 'package:todo_note_app/feature/todos/domain/models/note_model.dart';


// 1. Provider cung cấp Repository
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// 2. Notifier điều khiển danh sách ghi chú
class NoteListNotifier extends Notifier<List<NoteModel>> {
  @override
  List<NoteModel> build() {
    _loadNotes();
    return [];
  }

  Future<void> _loadNotes() async {
    final repo = ref.read(noteRepositoryProvider);
    state = await repo.loadNotes();
  }

  Future<void> addNote(NoteModel note) async {
    state = [note, ...state];
    await ref.read(noteRepositoryProvider).saveNotes(state);
  }

  Future<void> updateNote(NoteModel updated) async {
    state = [
      for (final note in state)
        if (note.id == updated.id) updated else note,
    ];
    await ref.read(noteRepositoryProvider).saveNotes(state);
  }

  Future<void> togglePin(String id) async {
    state = [
      for (final note in state)
        if (note.id == id)
          note.copyWith(isPinned: !note.isPinned)
        else
          note,
    ];
    await ref.read(noteRepositoryProvider).saveNotes(state);
  }

  Future<void> deleteNote(String id) async {
    state = state.where((note) => note.id != id).toList();
    await ref.read(noteRepositoryProvider).saveNotes(state);
  }
}

// ⭐ ĐÂY CHÍNH LÀ noteListProvider MÀ BẠN ĐANG TÌM ⭐
final noteListProvider =
    NotifierProvider<NoteListNotifier, List<NoteModel>>(NoteListNotifier.new);

// 3. Quản lý từ khóa tìm kiếm của ghi chú
class NoteSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final noteSearchQueryProvider =
    NotifierProvider<NoteSearchQueryNotifier, String>(
        NoteSearchQueryNotifier.new);

// 4. Quản lý bộ lọc theo thẻ #tag
class NoteTagFilterNotifier extends Notifier<String> {
  @override
  String build() => 'Tất cả';
  void setTag(String tag) => state = tag;
}

final noteTagFilterProvider =
    NotifierProvider<NoteTagFilterNotifier, String>(
        NoteTagFilterNotifier.new);

// 5. Tập hợp tất cả các tag duy nhất có trong các ghi chú
final noteAllTagsProvider = Provider<List<String>>((ref) {
  final notes = ref.watch(noteListProvider);
  final tagsSet = <String>{'Tất cả'};
  for (final n in notes) {
    tagsSet.addAll(n.tags);
  }
  return tagsSet.toList();
});

// 6. Danh sách ghi chú đã lọc & sắp xếp (Đã ghim lên đầu, mới sửa xếp trước)
final filteredNotesProvider = Provider<List<NoteModel>>((ref) {
  final notes = ref.watch(noteListProvider);
  final searchQuery = ref.watch(noteSearchQueryProvider).toLowerCase().trim();
  final tagFilter = ref.watch(noteTagFilterProvider);

  return notes.where((note) {
    // Lọc theo tag
    if (tagFilter != 'Tất cả' && !note.tags.contains(tagFilter)) {
      return false;
    }

    // Lọc theo từ khóa
    if (searchQuery.isNotEmpty) {
      final matchesTitle = note.title.toLowerCase().contains(searchQuery);
      final matchesContent = note.content.toLowerCase().contains(searchQuery);
      if (!matchesTitle && !matchesContent) return false;
    }

    return true;
  }).toList()
    ..sort((a, b) {
      // Ưu tiên ghi chú đã ghim lên đầu
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      // Sau đó sắp xếp theo thời gian cập nhật gần nhất
      return b.updatedAt.compareTo(a.updatedAt);
    });
});