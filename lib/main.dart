import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/home/presentation/views/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Bọc ProviderScope ở lớp cao nhất
  runApp(const ProviderScope(child: TodoNoteApp()));
}

class TodoNoteApp extends ConsumerWidget {
  const TodoNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đọc trạng thái Sáng / Tối từ Riverpod
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Todo & Note App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}