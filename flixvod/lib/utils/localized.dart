import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Centralized localization utility class.
/// Provides static access to localized strings throughout the app.
/// 
/// Usage:
/// ```dart
/// Text(Localized.of(context).retry)
/// Text(Localized.of(context).deleteConfirmation('Movie Title'))
/// ```
class Localized {
  /// Get AppLocalizations for the given context with null safety
  static AppLocalizations of(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      throw FlutterError(
        'Localized.of() called with a context that does not contain AppLocalizations.\n'
        'Make sure your app is properly configured with localization delegates.',
      );
    }
    return localizations;
  }
}
