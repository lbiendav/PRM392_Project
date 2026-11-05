import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  /// Format tiền tệ Việt Nam Đồng (VNĐ): Ví dụ: 45000 -> "45.000 ₫"
  static String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format ngày: dd/MM/yyyy (Ví dụ: 05/11/2026)
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format ngày giờ: dd/MM/yyyy HH:mm (Ví dụ: 05/11/2026 14:30)
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Chuyển đổi String ngày 'dd/MM/yyyy' sang DateTime
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
