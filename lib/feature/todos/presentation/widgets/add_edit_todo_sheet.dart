import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_note_app/feature/todos/domain/models/todo_model.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_note_app/core/constants/app_colors.dart';

class AddEditTodoSheet extends StatefulWidget {
  // Nếu todo == null nghĩa là người dùng đang "Thêm mới"
  // Nếu todo != null nghĩa là người dùng đang "Chỉnh sửa" todo có sẵn
  final TodoModel? todo;
  final Function(TodoModel) onSave;

  const AddEditTodoSheet({
    super.key,
    this.todo,
    required this.onSave,
  });

  @override
  State<AddEditTodoSheet> createState() => _AddEditTodoSheetState();
}

class _AddEditTodoSheetState extends State<AddEditTodoSheet> {
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển ô nhập chữ
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late String _priority;
  late String _category;
  DateTime? _selectedDueDate;

  final List<String> _categories = [
    'Công việc',
    'Cá nhân',
    'Học tập',
    'Mua sắm',
    'Sức khỏe',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu (nếu là sửa thì lấy từ todo cũ sang)
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descController = TextEditingController(text: widget.todo?.description ?? '');
    _priority = widget.todo?.priority ?? 'medium';
    _category = widget.todo?.category ?? 'Công việc';
    _selectedDueDate = widget.todo?.dueDate;
  }

  // 🧹 Giải phóng bộ nhớ RAM khi đóng bảng này lại
  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Hàm mở hộp thoại chọn Ngày & Giờ
  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    // 1. Chọn ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (pickedDate != null && mounted) {
      // 2. Chọn giờ
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDueDate != null
            ? TimeOfDay.fromDateTime(_selectedDueDate!)
            : const TimeOfDay(hour: 9, minute: 0),
      );

      setState(() {
        if (pickedTime != null) {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            23,
            59,
          );
        }
      });
    }
  }

  // Hàm xử lý khi bấm nút "Lưu" hoặc "Thêm việc"
  void _submit() {
    // Kiểm tra tính hợp lệ của Form (bắt buộc nhập tiêu đề)
    if (!_formKey.currentState!.validate()) return;

    final id = widget.todo?.id ?? const Uuid().v4(); // Sinh ID ngẫu nhiên nếu là tạo mới
    final newTodo = TodoModel(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      isCompleted: widget.todo?.isCompleted ?? false,
      dueDate: _selectedDueDate,
      priority: _priority,
      category: _category,
      createdAt: widget.todo?.createdAt ?? DateTime.now(),
    );

    widget.onSave(newTodo);
    Navigator.of(context).pop(); // Tắt bảng trượt đi sau khi lưu
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        // Đẩy giao diện lên trên khi bàn phím ảo xuất hiện
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề đầu bảng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Chỉnh sửa công việc' : 'Thêm công việc mới',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ô nhập Tiêu đề
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề công việc *',
                  hintText: 'Nhập việc bạn cần làm...',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Ô nhập Ghi chú thêm
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú thêm',
                  hintText: 'Chi tiết công việc (tùy chọn)...',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Chọn Độ ưu tiên (Thấp / Trung bình / Cao)
              Text('Độ ưu tiên:', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  _priorityChoice('low', 'Thấp', AppColors.priorityLow),
                  const SizedBox(width: 8),
                  _priorityChoice('medium', 'Trung bình', AppColors.priorityMedium),
                  const SizedBox(width: 8),
                  _priorityChoice('high', 'Cao', AppColors.priorityHigh),
                ],
              ),
              const SizedBox(height: 16),

              // Chọn Danh mục
              Text('Danh mục:', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _category == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _category = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Chọn Ngày/Giờ hết hạn
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(
                        _selectedDueDate == null
                            ? 'Chọn ngày hết hạn'
                            : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDueDate!),
                        style: const TextStyle(fontSize: 13),
                      ),
                      onPressed: _pickDateTime,
                    ),
                  ),
                  if (_selectedDueDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () => setState(() => _selectedDueDate = null),
                      tooltip: 'Xóa ngày hạn',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Nút Bấm Xác Nhận
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Lưu thay đổi' : 'Thêm công việc'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con hiển thị từng ô lựa chọn Độ ưu tiên
  Widget _priorityChoice(String value, String label, Color color) {
    final isSelected = _priority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 4, backgroundColor: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}