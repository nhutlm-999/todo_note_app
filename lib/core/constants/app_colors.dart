import 'package:flutter/material.dart';

class AppColors {
  // Private constructor ngăn việc tạo instance
  AppColors._();

  // Màu sắc theo mức độ ưu tiên
  static const Color priorityLow = Color(0xFF10B981);     // Xanh lục ngọc
  static const Color priorityMedium = Color(0xFFF59E0B);  // Vàng cam
  static const Color priorityHigh = Color(0xFFEF4444);    // Đỏ tươi

  // Bảng 8 màu pastel nhẹ nhàng cho Note (phong cách Google Keep)
  static const List<int> noteColorValues = [
    0x00000000, // 0 = Trong suốt (mặc định ăn theo màu Card của Theme)
    0xFFFFF9C4, // Vàng pastel
    0xFFFFCCBC, // San hô pastel
    0xFFC8E6C9, // Bạc hà pastel
    0xFFB3E5FC, // Xanh trời pastel
    0xFFE1BEE7, // Oải hương pastel
    0xFFFFD180, // Cam đào pastel
    0xFFCFD8DC, // Xám đá pastel
  ];

  // Hàm tiện ích lấy màu theo chuỗi ưu tiên
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
      default:
        return priorityLow;
    }
  }
}