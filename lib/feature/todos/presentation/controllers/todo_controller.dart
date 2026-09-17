import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/todos/data/todo_repository.dart';
import 'package:todo_note_app/feature/todos/domain/models/todo_model.dart';

// Provider cung cấp Repository
final todoRepositoryProvider = Provider<TodoRepository>((ref) => TodoRepository());

// Lớp điều khiển danh sách công việc
class TodoListNotifier extends Notifier<List<TodoModel>> {
  @override
  List<TodoModel> build() {
    _loadTodos();
    return []; // Khởi đầu rỗng, sau đó nạp từ disk
  }

  Future<void> _loadTodos () async {
    final repo = ref.read(todoRepositoryProvider);
    state = await repo.loadTodos();
  }

  Future<void> addTodo(TodoModel todo) async {
    state = [todo, ...state]; // Đưa việc mới lên đầu
    await ref.read(todoRepositoryProvider).saveTodos(state);
  }

  Future<void> updateTodo(TodoModel updated) async {
    state = [
      for (final todo in state)
        if (todo.id == updated.id) updated else todo,
    ];
    await ref.read(todoRepositoryProvider).saveTodos(state);
  }
  Future<void> toggleTodoStatus(String id) async {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
    await ref.read(todoRepositoryProvider).saveTodos(state);
  }
  Future<void> deleteTodo(String id) async {
    state = state.where((todo) => todo.id != id).toList();
    await ref.read(todoRepositoryProvider).saveTodos(state);
  }
}
// Khởi tạo Provider để UI có thể ref.watch hoặc ref.read
final todoListProvider =
    NotifierProvider<TodoListNotifier, List<TodoModel>>(TodoListNotifier.new);

// Bộ lọc trạng thái: Tất cả / Đang làm / Đã xong
enum TodoFilter { all, active, completed }

class TodoStatusFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;
  void setFilter(TodoFilter filter) => state = filter;
}

final todoStatusFilterProvider =
    NotifierProvider<TodoStatusFilterNotifier, TodoFilter>(TodoStatusFilterNotifier.new);

// 1. Quản lý bộ lọc danh mục (Công việc, Cá nhân, Học tập, ...)
class TodoCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'Tất cả'; // Mặc định là hiển thị 'Tất cả'

  void setCategory(String category) {
    state = category; // Cập nhật danh mục được chọn
  }
}

// Khởi tạo Provider để UI và filteredTodoListProvider có thể gọi
final todoCategoryFilterProvider =
    NotifierProvider<TodoCategoryFilterNotifier, String>(
        TodoCategoryFilterNotifier.new);

// 2. Quản lý bộ lọc tìm kiếm
class TodoSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => ''; // Mặc định là không tìm kiếm
  void setSearchQuery(String query) {
    state = query; // Cập nhật chuỗi tìm kiếm
  }
}

final todoSearchQueryProvider =
    NotifierProvider<TodoSearchQueryNotifier, String>(
        TodoSearchQueryNotifier.new);


// Provider tự động tính toán danh sách đã lọc & sắp xếp
final filteredTodoListProvider = Provider<List<TodoModel>>((ref) {
  final todos = ref.watch(todoListProvider);
  final statusFilter = ref.watch(todoStatusFilterProvider);

  
  final categoryFilter = ref.watch(todoCategoryFilterProvider);
  final searchQuery = ref.watch(todoSearchQueryProvider).toLowerCase().trim();

  return todos.where((todo) {
    if (statusFilter == TodoFilter.active && todo.isCompleted) return false;
    if (statusFilter == TodoFilter.completed && !todo.isCompleted) return false;
    if (categoryFilter != 'Tất cả' && todo.category != categoryFilter) return false;

    if (searchQuery.isNotEmpty) {
      final matchesTitle = todo.title.toLowerCase().contains(searchQuery);
      final matchesDesc = todo.description.toLowerCase().contains(searchQuery);
      if (!matchesTitle && !matchesDesc) return false;
    }
    return true;
  }).toList()
    ..sort((a, b) {
      // Việc đã hoàn thành tự động trôi xuống dưới cùng
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Ưu tiên sắp xếp theo hạn chót gần nhất
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
});

// Provider tự tính % tiến độ
final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todoListProvider);
  final total = todos.length;
  final completed = todos.where((t) => t.isCompleted).length;
  return {
    'total': total,
    'completed': completed,
    'active': total - completed,
  };
});