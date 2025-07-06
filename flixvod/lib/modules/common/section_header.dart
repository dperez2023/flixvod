import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final IconData icon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppTheme.largeIconSize,
          color: AppTheme.primaryForegroundColor,
        ),
        AppTheme.largeHorizontalSpacer,
        Text(
          title,
          style: AppTheme.primaryTextStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppTheme.mediumHorizontalSpacer,
        if (count != null && count! > 0) 
          Container(
          padding: AppTheme.badgePadding,
          decoration: AppTheme.createBadgeDecoration(AppTheme.overlayBackgroundColor),
          child: Text(
            count.toString(),
            style: AppTheme.badgeTextStyle,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
