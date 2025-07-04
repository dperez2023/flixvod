import 'package:flutter/material.dart';

/// A reusable widget to show notification messages using SnackBar and color-coded backgrounds
class NotificationMessageWidget {
  static void showSuccess(BuildContext context, String message) {
    _showMessage(context, message, Colors.green);
  }

  static void showError(BuildContext context, String message) {
    _showMessage(context, message, Colors.red);
  }

  static void showInfo(BuildContext context, String message) {
    _showMessage(context, message, Colors.blue);
  }

  static void showWarning(BuildContext context, String message) {
    _showMessage(context, message, Colors.orange);
  }

  static void _showMessage(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
