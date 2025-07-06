import 'package:flutter/material.dart';
import '../../localization/localized.dart';
import '../../core/app_theme.dart';

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
          Icon(Icons.error, size: 64, color: AppTheme.errorColor),
          AppTheme.mediumVerticalSpacer,
          Text(
            errorMessage ?? Localized.of(context).anErrorOccurred,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          AppTheme.mediumVerticalSpacer,
          ElevatedButton(
            onPressed: onRetry,
            child: Text(Localized.of(context).retry),
          ),
        ],
      ),
    );
  }
}
