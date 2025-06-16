import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime? date, {String pattern = 'dd/MM/yyyy'}) {
    if (date == null) return '-';
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(
    DateTime? date, {
    String pattern = 'dd/MM/yyyy HH:mm',
  }) {
    if (date == null) return '-';
    return DateFormat(pattern).format(date);
  }

  static String formatTimeAgo(DateTime? date) {
    if (date == null) return '-';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Number formatting
  static String formatNumber(num? number, {int decimalPlaces = 0}) {
    if (number == null) return '-';
    return NumberFormat(
      '#,##0${decimalPlaces > 0 ? '.${'0' * decimalPlaces}' : ''}',
    ).format(number);
  }

  static String formatCurrency(num? amount, {String symbol = '\$'}) {
    if (amount == null) return '-';
    return NumberFormat.currency(symbol: symbol).format(amount);
  }

  static String formatPercentage(num? value, {int decimalPlaces = 1}) {
    if (value == null) return '-';
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }

  // String utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  static String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Status helpers
  static String getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'C':
        return 'Created';
      case 'A':
        return 'Active';
      case 'I':
        return 'Inactive';
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'C':
        return Colors.blue;
      case 'A':
        return Colors.green;
      case 'I':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'manager':
        return 'Manager';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  // Device helpers
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // Debounce helper
  static void debounce(VoidCallback action, Duration delay) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, action);
  }

  // Loading state helper
  static Widget buildLoadingWidget({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[const SizedBox(height: 16), Text(message)],
        ],
      ),
    );
  }

  // Error state helper
  static Widget buildErrorWidget({
    required String message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ],
      ),
    );
  }

  // Empty state helper
  static Widget buildEmptyWidget({
    required String message,
    IconData icon = Icons.inbox_outlined,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }

  // Show snackbar helper
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  // Show success message
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 1),
    );
  }

  // Show error message
  static void showError(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Safe navigation
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }

  static void navigateAndReplace(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  static void navigateAndClearStack(BuildContext context, Widget page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}

// Timer utility for debouncing
class Timer {
  static Timer? _instance;

  Timer._(Duration duration, VoidCallback callback) {
    Future.delayed(duration, callback);
  }

  factory Timer(Duration duration, VoidCallback callback) {
    return Timer._(duration, callback);
  }

  void cancel() {
    // Implementation would depend on the actual timer mechanism
  }
}
