import 'package:flutter/material.dart';

// Import tiện ích thời gian và model
import 'package:todo_note_app/core/utils/date_formatter.dart';
import 'package:todo_note_app/feature/todos/domain/models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomColor = note.colorValue != 0;
    
    // Nếu note có màu pastel thì dùng màu đó, ngược lại dùng màu Card mặc định
    final cardColor = isCustomColor
        ? Color(note.colorValue)
        : theme.cardTheme.color ?? theme.colorScheme.surface;

    final textColor = isCustomColor ? Colors.black87 : theme.textTheme.bodyMedium?.color;

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart, // Vuốt sang trái để xóa
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            // Nếu đã ghim thì viền màu xanh nổi bật
            color: note.isPinned
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
            width: note.isPinned ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng tiêu đề & Nút ghim
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Không có tiêu đề' : note.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 20,
                        color: note.isPinned
                            ? theme.colorScheme.primary
                            : Colors.grey.shade500,
                      ),
                      onPressed: onTogglePin,
                      tooltip: note.isPinned ? 'Bỏ ghim' : 'Ghim ghi chú',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                // Nội dung tóm tắt
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isCustomColor ? Colors.black54 : Colors.grey.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Thẻ Tag và Thời gian sửa đổi
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: note.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCustomColor
                                  ? Colors.black.withValues(alpha: 0.06)
                                  : theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isCustomColor ? Colors.black87 : theme.colorScheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Text(
                      DateFormatter.formatFriendlyDate(note.updatedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isCustomColor ? Colors.black45 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}