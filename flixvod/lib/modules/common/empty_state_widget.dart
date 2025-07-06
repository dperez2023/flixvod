import 'package:flixvod/localization/localized.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_icons.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final VoidCallback? onRefresh;
  final String? refreshButtonText;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
    this.onRefresh,
    this.refreshButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.mutedForegroundColor),
          AppTheme.mediumVerticalSpacer,
          Text(
            message,
            style: AppTheme.emptyStateTitleStyle,
          ),
          if (subtitle != null) ...[
            AppTheme.smallVerticalSpacer,
            Text(
              subtitle!,
              style: AppTheme.emptyStateSubtitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
          if (onRefresh != null) ...[
            AppTheme.largeVerticalSpacer,
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: AppIcons.refresh,
              label: Text(refreshButtonText ?? Localized.of(context).refresh),
            ),
          ],
        ],
      ),
    );
  }
}
