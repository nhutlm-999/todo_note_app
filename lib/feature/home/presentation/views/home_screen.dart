import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/notes/presentation/views/notes_view.dart';
import 'package:todo_note_app/feature/todos/presentation/controllers/note_controller.dart';
import 'package:todo_note_app/feature/todos/presentation/controllers/todo_controller.dart';
import 'package:todo_note_app/feature/todos/presentation/views/todos_view.dart';


// Quản lý trạng thái Sáng / Tối (ThemeMode)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0; // 0: Công việc, 1: Ghi chú
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Widget> _views = const [
    TodosView(),
    NotesView(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Cập nhật từ khóa tìm kiếm sang đúng Provider của Tab đang mở
  void _onSearchChanged(String query) {
    if (_currentIndex == 0) {
      ref.read(todoSearchQueryProvider.notifier).setSearchQuery(query);
    } else {
      ref.read(noteSearchQueryProvider.notifier).setQuery(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: _currentIndex == 0
                      ? 'Tìm kiếm việc cần làm...'
                      : 'Tìm kiếm ghi chú...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(
                    _currentIndex == 0
                        ? Icons.check_circle_outline_rounded
                        : Icons.note_alt_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentIndex == 0 ? 'Công Việc (Todo)' : 'Ghi Chú (Note)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        actions: [
          // Nút kính lúp Tìm kiếm
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Tìm kiếm',
              onPressed: () => setState(() => _isSearching = true),
            ),
          // Nút chuyển đổi Giao diện Sáng / Tối
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Chuyển đổi giao diện Sáng / Tối',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      // IndexedStack giúp giữ nguyên vị trí cuộn khi đổi qua lại giữa 2 tab
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      // Thanh NavigationBar ở dưới đáy
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _onSearchChanged(_searchController.text);
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Công việc',
          ),
          NavigationDestination(
            icon: Icon(Icons.notes_rounded),
            selectedIcon: Icon(Icons.notes_rounded),
            label: 'Ghi chú',
          ),
        ],
      ),
    );
  }
}