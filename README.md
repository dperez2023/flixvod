# FlixVOD

Video on Demand (VOD) App built using Flutter and Firebase for iOS and Android, providing upload, streaming, and edit/add video content directly in the app

- **Introductory Video**: URL

## Features

### Core VOD Functionality
- **Video Upload**: Upload videos directly from mobile/desktop
- **Video Streaming**: High-quality video playback with full-screen support
- **Video Management**: Delete videos with confirmation dialogs
- **Search & Filter**: Search by title/description, filter by type (Movie/Series)
- **Cross-Platform**: Runs on iOS and Android

### Technical Features
- **Firebase Backend**: Cloud storage and database (thresholds set for free tier)
- **BLOC Architecture**: Clean state management with flutter_bloc
- **Modern UI**: Material Design 3 with responsive layouts
- **Performance**: Optimized video streaming and caching

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK** (3.5.4+)
- **Dart SDK** (3.5.4+)
- **Android Studio** (for Android development)
  - Android SDK (API level 21+)
  - Java JDK 8+
- **Xcode** (for iOS development) - Avoid Xcode 26 and iOS 26 debug
  - iOS 11.0+

## Usage Guide

### Uploading Movies and Series
1. Tap the **+** button in the top-right corner
2. Select a video file
3. Optionally select a thumbnail image
4. Fill in title, description, and metadata
5. Choose type (Movie/Series) and genres
6. Tap **Upload** and wait for completion

### Managing Movies and Series
- **View**: Tap any card to see details and play
- **Delete**: Long-press a card to delete (with confirmation)
- **Search**: Use the search bar to find specific content
- **Filter**: Tap filter chips to show only Movies or Series

### Video Playback (Chewie Library)
- Tap to open the media detail page (or directly the play button if a movie)
- Tap **Play** to start full-screen video playback
- Use player controls for play/pause, seek, and volume
- Tap back or use gestures to exit full-screen
