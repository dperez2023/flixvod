import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class InitializingScreen extends StatelessWidget {
  const InitializingScreen({super.key});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                size: 80,
                color: Colors.deepPurple[300],
              ),
              AppTheme.largeVerticalSpacer,
              Text(
                'FlixVOD',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              AppTheme.extraLargeVerticalSpacer,
              const CircularProgressIndicator(),
              AppTheme.mediumVerticalSpacer,
              Text(
                'Initializing...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mutedForegroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
