import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/todos/presentation/controllers/todo_controller.dart';
import 'package:todo_note_app/feature/todos/presentation/widgets/add_edit_todo_sheet.dart';
import 'package:todo_note_app/feature/todos/presentation/widgets/todo_item_tile.dart';


class TodosView extends ConsumerWidget {
  const TodosView({super.key});

  // Mở bảng BottomSheet thêm / sửa việc
  void _showAddEditSheet(BuildContext context, WidgetRef ref, [todo]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddEditTodoSheet(
        todo: todo,
        onSave: (savedTodo) {
          if (todo == null) {
            ref.read(todoListProvider.notifier).addTodo(savedTodo);
          } else {
            ref.read(todoListProvider.notifier).updateTodo(savedTodo);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lắng nghe danh sách công việc đã lọc
    final todos = ref.watch(filteredTodoListProvider);
    // 2. Lắng nghe số liệu thống kê
    final stats = ref.watch(todoStatsProvider);
    final currentFilter = ref.watch(todoStatusFilterProvider);
    final currentCategory = ref.watch(todoCategoryFilterProvider);
    final theme = Theme.of(context);

    final total = stats['total'] ?? 0;
    final completed = stats['completed'] ?? 0;
    final progress = total > 0 ? (completed / total) : 0.0;

    final categories = ['Tất cả', 'Công việc', 'Cá nhân', 'Học tập', 'Mua sắm', 'Sức khỏe', 'Khác'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Thẻ Card Tiến Độ %
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tiến độ hoàn thành',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$completed / $total việc đã xong',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Thanh lọc trạng thái (Tất cả / Đang làm / Đã xong)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SegmentedButton<TodoFilter>(
                segments: const [
                  ButtonSegment(value: TodoFilter.all, label: Text('Tất cả')),
                  ButtonSegment(value: TodoFilter.active, label: Text('Đang làm')),
                  ButtonSegment(value: TodoFilter.completed, label: Text('Đã xong')),
                ],
                selected: {currentFilter},
                onSelectionChanged: (selection) {
                  ref.read(todoStatusFilterProvider.notifier).setFilter(selection.first);
                },
              ),
            ),

            // Các Chip lọc theo Danh mục (Cuộn ngang)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = currentCategory == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(todoCategoryFilterProvider.notifier).setCategory(
                          selected ? cat : 'Tất cả');
                    },
                  );
                },
              ),
            ),

            // Danh Sách Công Việc
            Expanded(
              child: todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có công việc nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text('Bấm nút + bên dưới để thêm công việc mới', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return TodoItemTile(
                          todo: todo,
                          onToggle: () {
                            ref.read(todoListProvider.notifier).toggleTodoStatus(todo.id);
                          },
                          onTap: () => _showAddEditSheet(context, ref, todo),
                          onDelete: () {
                            ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xóa "${todo.title}"'),
                                action: SnackBarAction(
                                  label: 'Hoàn tác',
                                  onPressed: () {
                                    ref.read(todoListProvider.notifier).addTodo(todo);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSheet(context, ref),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Thêm việc'),
      ),
    );
  }
}