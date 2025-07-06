import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import '../modules/catalogue/bloc/catalogue_bloc.dart';
import '../modules/catalogue/pages/catalogue_page.dart';
import '../modules/common/firebase_error_screen.dart';
import '../modules/common/initializing_screen.dart';
import '../services/storage/firebase_service.dart';
import '../services/storage/firebase_options.dart';

enum AppState { initializing, initialized, error }

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppState _appState = AppState.initializing;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add delay for iOS 26 beta stability
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Initialize Firebase with iOS 26 beta specific timeout
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Firebase initialization timed out', const Duration(seconds: 30));
        },
      );
      
      // Additional delay for iOS 26 beta
      await Future.delayed(const Duration(milliseconds: 300));
      
      await FirebaseService.initialize();
      
      // Success
      if (mounted) {
        setState(() {
          _appState = AppState.initialized;
        });
      }
    } catch (e) {
      // Error
      if (mounted) {
        setState(() {
          _appState = AppState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _retryInitialization() {
    setState(() {
      _appState = AppState.initializing;
      _errorMessage = null;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    switch (_appState) {
      case AppState.initializing:
        return const InitializingScreen();
      case AppState.initialized:
        return BlocProvider(
          create: (context) => CatalogueBloc(),
          child: const CataloguePage(),
        );
      case AppState.error:
        return FirebaseErrorScreen(
          error: _errorMessage ?? 'Unknown error',
          onRetry: _retryInitialization,
        );
    }
  }
}
