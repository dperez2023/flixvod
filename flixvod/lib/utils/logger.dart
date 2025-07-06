import 'package:flutter/foundation.dart';

class FlixLogger {
  FlixLogger._();

  static final FlixLogger _instance = FlixLogger._();
  static FlixLogger get instance => _instance;
  
  void d(dynamic message) {
    if (kDebugMode) {
      debugPrint('[FlixVOD] ${message.toString()}');
    }
  }
  
  void e(dynamic message, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[FlixVOD ERROR] ${message.toString()}');
      if (stackTrace != null) {
        debugPrint('[FlixVOD STACK] $stackTrace');
      }
    }
  }

  void w(dynamic message) {
    if (kDebugMode) {
      debugPrint('[FlixVOD WARN] ${message.toString()}');
    }
  }

  void i(dynamic message) {
    if (kDebugMode) {
      debugPrint('[FlixVOD INFO] ${message.toString()}');
    }
  }
}

final logger = FlixLogger.instance;
