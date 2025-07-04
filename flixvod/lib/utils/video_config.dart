class VideoConfig {
  // Configuration for different environments
  static const String environment = 'production';
  
  // Firebase Storage configuration
  static const String firebaseStorageBase = 'https://firebasestorage.googleapis.com/v0/b/flixvod-41083.appspot.com/o/videos%2F';
  
  // Get Firebase Storage base URL
  static String get baseVideoUrl => firebaseStorageBase;
}
