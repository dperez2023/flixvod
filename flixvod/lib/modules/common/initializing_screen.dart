import 'package:flutter/material.dart';

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
              const SizedBox(height: 24),
              Text(
                'FlixVOD',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Initializing...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
