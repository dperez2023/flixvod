import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';
import '../../models/media.dart';
import '../../logger.dart';
import '../../localization/localized.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Media media;

  const VideoPlayerScreen({
    super.key,
    required this.media,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}  

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showTopBar = true;
  Timer? _hideTimer;
  final int _hideDelay = 5;

  @override
  void initState() {
    super.initState();
    
    // Set landscape mode and "immersive" UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Only landscape orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize video player here where Theme.of(context) is available
    if (_videoPlayerController == null && _errorMessage == null) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    // Ensure orientation is restored when disposing (reset orientation have to cases: Reset by back button or by dispose)
    _resetOrientation();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: _hideDelay), () {
      if (mounted) {
        setState(() {
          _showTopBar = false;
        });
      }
    });
  }

  void _resetOrientation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _goBack() {
    _resetOrientation();
    Navigator.of(context).pop();
  }

  void _showTopBarAndResetTimer() {
    setState(() {
      _showTopBar = true;
    });
    _startHideTimer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final primaryColor = Theme.of(context).primaryColor;
      
      String? videoUrl = widget.media.videoUrl;
      
      if (videoUrl == null || videoUrl.isEmpty) {
        logger.e('No video URL provided for media: ${widget.media.title}');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Video URL not available';
        });
        return;
      }
      
      logger.d('Initializing video player for: ${widget.media.title} using URL: $videoUrl');
      
      // Initialize with progressive streaming optimization (using range requests)
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'Cache-Control': 'no-cache',
          'Accept-Ranges': 'bytes',
        },
      );
      
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        allowedScreenSleep: false,
        showControlsOnInitialize: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: primaryColor,
          handleColor: primaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey[300]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          logger.e('Video player error: $errorMessage');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  Localized.of(context).errorPlayingVideo,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _goBack,
                  child: Text(Localized.of(context).goBack),
                ),
              ],
            ),
          );
        },
      );
      
      setState(() {
        _isLoading = false;
      });
      _startHideTimer();
      logger.d('Video player initialized successfully');
    } catch (e, s) {
      logger.e('Failed to initialize video player: $e', s);
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    Localized.of(context).loadingVideo,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Localized.of(context).failedToLoadVideo,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _goBack,
                        child: Text(Localized.of(context).goBack),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Video player
                    Center(
                      child: _chewieController != null
                          ? Chewie(controller: _chewieController!)
                          : const CircularProgressIndicator(),
                    ),
                    // Full-screen transparent overlay for tap detection
                    if (!_showTopBar)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _showTopBarAndResetTimer,
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),

                      if (_showTopBar)
                        Positioned(
                          top: 40,
                          left: 16,
                          child: SafeArea(
                            child: GestureDetector(
                              onTap: _goBack,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
    );
  }
}
