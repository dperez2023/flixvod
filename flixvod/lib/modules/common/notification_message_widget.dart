import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// A reusable widget to show notification messages using SnackBar and color-coded backgrounds
class NotificationMessageWidget {
  static void showSuccess(BuildContext context, String message) {
    _showMessage(context, message, AppTheme.successColor);
  }

  static void showError(BuildContext context, String message) {
    _showMessage(context, message, AppTheme.errorColor);
  }

  static void showInfo(BuildContext context, String message) {
    _showMessage(context, message, AppTheme.infoColor);
  }

  static void showWarning(BuildContext context, String message) {
    _showMessage(context, message, AppTheme.warningColor);
  }

  static void _showMessage(BuildContext context, String message, Color backgroundColor) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.primaryTextStyle,
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AppTheme.primaryForegroundColor,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
