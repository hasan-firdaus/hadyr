import 'package:intl/intl.dart';

class AppUtils {
  /// Format DateTime ke "Senin, 25 Nov 2024"
  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
  }

  /// Format DateTime ke "25 Nov 2024"
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  /// Format DateTime ke "25/11/2024"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format time ke "08:00 - 10:30"
  static String formatTimeRange(String start, String end) {
    return '$start - $end';
  }

  /// Validator untuk field kosong
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validator email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Validator password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  /// Hitung persentase kehadiran
  static double calcAttendancePercent(int hadir, int total) {
    if (total == 0) return 0;
    return (hadir / total) * 100;
  }

  /// Singkat nama panjang
  static String shortenName(String name, {int maxLength = 20}) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength)}...';
  }
}
