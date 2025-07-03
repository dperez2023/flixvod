import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCnbXvt2oLjNHRbfThxxYun8CU0_eq2MVs',
    appId: '1:1097325740860:android:8960bb4aa6ed439601d439',
    messagingSenderId: '1097325740860',
    projectId: 'flixvod-41083',
    storageBucket: 'flixvod-41083.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJwpHUgXk4nBIwx-AMsAWlkfCjSuHP9oY',
    appId: '1:1097325740860:ios:5e486126d60f3e0f01d439',
    messagingSenderId: '1097325740860',
    projectId: 'flixvod-41083',
    storageBucket: 'flixvod-41083.firebasestorage.app',
    iosBundleId: 'com.example.flixvod',
  );
}