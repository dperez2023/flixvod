import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:async';
import '../../models/media.dart';
import '../../utils/logger.dart';
import '../../localization/localized.dart';
import '../../core/app_theme.dart';
import '../../core/app_icons.dart';

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
      
      String? videoUrl = widget.media.getVideoUrl();
      
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
          backgroundColor: AppTheme.primaryBorderColor,
          bufferedColor: AppTheme.playerBufferedColor,
        ),
        placeholder: Container(
          color: AppTheme.playerBackgroundColor,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          logger.e('Video player error: $errorMessage');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,                children: [
                  AppIcons.errorLarge,
                AppTheme.mediumVerticalSpacer,
                Text(
                  Localized.of(context).errorPlayingVideo,
                  style: AppTheme.playerTitleStyle,
                ),
                AppTheme.smallVerticalSpacer,
                Text(
                  errorMessage,
                  style: AppTheme.playerSubtitleStyle,
                  textAlign: TextAlign.center,
                ),
                AppTheme.mediumVerticalSpacer,
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
      backgroundColor: AppTheme.playerBackgroundColor,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.playerControlsColor),
                  AppTheme.mediumVerticalSpacer,
                  Text(
                    Localized.of(context).loadingVideo,
                    style: AppTheme.playerInfoStyle,
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcons.errorLarge,
                      AppTheme.mediumVerticalSpacer,
                      Text(
                        Localized.of(context).failedToLoadVideo,
                        style: AppTheme.playerTitleStyle,
                      ),
                      AppTheme.smallVerticalSpacer,
                      Text(
                        _errorMessage!,
                        style: AppTheme.playerSubtitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      AppTheme.mediumVerticalSpacer,
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
                                padding: AppTheme.smallPadding,
                                decoration: BoxDecoration(
                                  color: AppTheme.playerControlBackgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: AppIcons.back,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
    );
  }
}
