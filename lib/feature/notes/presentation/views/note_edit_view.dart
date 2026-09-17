import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_note_app/feature/todos/domain/models/note_model.dart';
import 'package:todo_note_app/feature/todos/presentation/controllers/note_controller.dart';
import 'package:uuid/uuid.dart';

import 'package:todo_note_app/core/constants/app_colors.dart';


class NoteEditView extends ConsumerStatefulWidget {
  final NoteModel? note;

  const NoteEditView({super.key, this.note});

  @override
  ConsumerState<NoteEditView> createState() => _NoteEditViewState();
}

class _NoteEditViewState extends ConsumerState<NoteEditView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late bool _isPinned;
  late int _selectedColor;
  late List<String> _tags;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagInputController = TextEditingController();
    _isPinned = widget.note?.isPinned ?? false;
    _selectedColor = widget.note?.colorValue ?? 0;
    _tags = List.from(widget.note?.tags ?? []);

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  // Dọn dẹp RAM khi thoát
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  // Tự động lưu ghi chú
  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _tags.isEmpty) {
      return; // Không lưu nếu ghi chú rỗng hoàn toàn
    }

    final id = widget.note?.id ?? const Uuid().v4();
    final now = DateTime.now();

    final note = NoteModel(
      id: id,
      title: title,
      content: content,
      isPinned: _isPinned,
      colorValue: _selectedColor,
      tags: _tags,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.note == null) {
      ref.read(noteListProvider.notifier).addNote(note);
    } else {
      ref.read(noteListProvider.notifier).updateNote(note);
    }
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _hasChanges = true;
      });
      _tagInputController.clear();
      Navigator.of(context).pop();
    }
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm thẻ Tag'),
        content: TextField(
          controller: _tagInputController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: Công việc, Ý tưởng...',
            prefixIcon: Icon(Icons.tag),
          ),
          onSubmitted: (_) => _addTag(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: _addTag,
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  // Bảng chọn màu nền tròn
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn màu nền', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.noteColorValues.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final colorVal = AppColors.noteColorValues[index];
                    final isDefault = colorVal == 0;
                    final isSelected = _selectedColor == colorVal;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = colorVal;
                          _hasChanges = true;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDefault ? Colors.white : Color(colorVal),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade400,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isDefault ? const Icon(Icons.format_color_reset, size: 18) : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCustomColor = _selectedColor != 0;
    final backgroundColor = isCustomColor ? Color(_selectedColor) : theme.scaffoldBackgroundColor;

    // PopScope: Bắt sự kiện bấm Back để tự động lưu
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _saveNote();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              _saveNote();
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: _isPinned ? theme.colorScheme.primary : null,
              ),
              tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim ghi chú',
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _hasChanges = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              tooltip: 'Đổi màu nền',
              onPressed: _showColorPicker,
            ),
            if (widget.note != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Xóa ghi chú',
                onPressed: () {
                  ref.read(noteListProvider.notifier).deleteNote(widget.note!.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Thanh chứa thẻ Tags
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ..._tags.map(
                              (tag) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Chip(
                                  label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                                  deleteIcon: const Icon(Icons.close, size: 14),
                                  onDeleted: () {
                                    setState(() {
                                      _tags.remove(tag);
                                      _hasChanges = true;
                                    });
                                  },
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.add, size: 16),
                              label: const Text('Thẻ', style: TextStyle(fontSize: 12)),
                              onPressed: _showTagDialog,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Ô nhập Tiêu đề & Nội dung
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'Tiêu đề ghi chú...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        decoration: const InputDecoration(
                          hintText: 'Bắt đầu viết ghi chú của bạn...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}