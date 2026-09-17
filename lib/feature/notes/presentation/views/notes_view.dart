import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/notes/presentation/views/note_edit_view.dart';
import 'package:todo_note_app/feature/todos/presentation/controllers/note_controller.dart';
import 'package:todo_note_app/feature/todos/presentation/widgets/note_card.dart';


class NotesView extends ConsumerWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(filteredNotesProvider);
    final tags = ref.watch(noteAllTagsProvider);
    final currentTag = ref.watch(noteTagFilterProvider);

    // Tách riêng ghi chú đã ghim và ghi chú thường
    final pinnedNotes = notes.where((n) => n.isPinned).toList();
    final otherNotes = notes.where((n) => !n.isPinned).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Các nút lọc theo Thẻ Tag (#tag)
            if (tags.length > 1)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: tags.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    final isSelected = currentTag == tag;
                    return FilterChip(
                      label: Text(tag == 'Tất cả' ? tag : '#$tag'),
                      selected: isSelected,
                      onSelected: (selected) {
                        ref.read(noteTagFilterProvider.notifier).setTag(
                            selected ? tag : 'Tất cả');
                      },
                    );
                  },
                ),
              ),

            // Danh Sách Ghi Chú
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có ghi chú nào',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text('Bấm nút + bên dưới để tạo ghi chú mới', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        // Nhóm Ghi Chú Đã Ghim
                        if (pinnedNotes.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 6, top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.push_pin, size: 14, color: Colors.grey),
                                SizedBox(width: 6),
                                Text(
                                  'ĐÃ GHIM',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          ...pinnedNotes.map((note) => NoteCard(
                                note: note,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => NoteEditView(note: note)),
                                ),
                                onTogglePin: () => ref.read(noteListProvider.notifier).togglePin(note.id),
                                onDelete: () => ref.read(noteListProvider.notifier).deleteNote(note.id),
                              )),
                          const SizedBox(height: 12),
                        ],
                        // Nhóm Ghi Chú Còn Lại
                        if (pinnedNotes.isNotEmpty && otherNotes.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 6),
                            child: Text(
                              'KHÁC',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey),
                            ),
                          ),
                        ...otherNotes.map((note) => NoteCard(
                              note: note,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => NoteEditView(note: note)),
                              ),
                              onTogglePin: () => ref.read(noteListProvider.notifier).togglePin(note.id),
                              onDelete: () => ref.read(noteListProvider.notifier).deleteNote(note.id),
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NoteEditView()),
        ),
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Tạo ghi chú'),
      ),
    );
  }
}