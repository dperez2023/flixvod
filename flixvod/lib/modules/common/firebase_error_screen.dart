import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class FirebaseErrorScreen extends StatefulWidget {
  final String error;
  final VoidCallback? onRetry;

  const FirebaseErrorScreen({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  State<FirebaseErrorScreen> createState() => _FirebaseErrorScreenState();
}

class _FirebaseErrorScreenState extends State<FirebaseErrorScreen> {
  bool _isRetrying = false;

  Future<void> _retryInitialization() async {
    if (widget.onRetry != null) {
      widget.onRetry!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixVOD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: AppTheme.largePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: AppTheme.heroIconSize,
                  color: AppTheme.lightForegroundColor,
                ),
                AppTheme.largeVerticalSpacer,
                Text(
                  'Connection Error',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppTheme.mediumVerticalSpacer,
                Text(
                  'Unable to connect to Firebase services. Please check your internet connection and try again.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mutedForegroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.error.isNotEmpty) ...[
                  AppTheme.mediumVerticalSpacer,
                  Container(
                    padding: AppTheme.containerPadding,
                    decoration: AppTheme.createErrorContainerDecoration(),
                    child: Text(
                      'Error: ${widget.error}',
                      style: AppTheme.errorDisplayStyle.copyWith(
                        color: AppTheme.errorTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                AppTheme.extraLargeVerticalSpacer,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRetrying ? null : _retryInitialization,
                    icon: _isRetrying
                        ? SizedBox(
                            width: AppTheme.loadingIndicatorSize,
                            height: AppTheme.loadingIndicatorSize,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isRetrying ? 'Retrying...' : 'Retry Connection'),
                    style: ElevatedButton.styleFrom(
                      padding: AppTheme.buttonPadding,
                    ),
                  ),
                ),
                AppTheme.mediumVerticalSpacer,
                Text(
                  'Make sure you have an active internet connection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightForegroundColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
