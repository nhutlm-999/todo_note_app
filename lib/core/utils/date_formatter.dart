import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  // Định dạng ngày thành văn bản thân thiện
  static String formatFriendlyDate(DateTime? date, {bool includeTime = true}) {
    if (date == null) return '';

    final now = DateTime.now();
    // Bỏ qua phần giờ phút giây để chỉ so sánh ngày
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    final differenceInDays = targetDay.difference(today).inDays;
    final timeStr = DateFormat('HH:mm').format(date);

    if (differenceInDays == 0) {
      return includeTime ? 'Hôm nay, $timeStr' : 'Hôm nay';
    } else if (differenceInDays == 1) {
      return includeTime ? 'Ngày mai, $timeStr' : 'Ngày mai';
    } else if (differenceInDays == -1) {
      return includeTime ? 'Hôm qua, $timeStr' : 'Hôm qua';
    } else {
      final dateStr = DateFormat('dd/MM/yyyy').format(date);
      return includeTime ? '$dateStr, $timeStr' : dateStr;
    }
  }

  // Kiểm tra xem công việc đã bị quá hạn hay chưa
  static bool isOverdue(DateTime? date, {bool isCompleted = false}) {
    // Nếu không đặt hạn hoặc việc đã làm xong thì không coi là quá hạn
    if (date == null || isCompleted) return false;
    return date.isBefore(DateTime.now());
  }
}