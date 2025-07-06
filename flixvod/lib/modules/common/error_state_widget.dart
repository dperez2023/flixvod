import 'package:flutter/material.dart';
import '../../localization/localized.dart';
import '../../core/app_theme.dart';
import '../../core/app_icons.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcons.errorLarge,
          AppTheme.mediumVerticalSpacer,
          Text(
            errorMessage ?? Localized.of(context).anErrorOccurred,
            style: AppTheme.emptyStateTitleStyle,
            textAlign: TextAlign.center,
          ),
          AppTheme.mediumVerticalSpacer,
          ElevatedButton(
            onPressed: onRetry,
            style: AppTheme.primaryElevatedButtonStyle,
            child: Text(Localized.of(context).retry),
          ),
        ],
      ),
    );
  }
}
