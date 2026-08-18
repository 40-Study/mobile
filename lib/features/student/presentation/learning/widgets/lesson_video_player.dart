import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:study/theme/theme.dart';

class LessonVideoPlayer extends StatefulWidget {
  const LessonVideoPlayer({super.key, this.videoUrl});
  final String? videoUrl;

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  // Sample video để test
  static const _sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_videoController == null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final url = widget.videoUrl ?? _sampleVideoUrl;
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController = controller;

      await controller.initialize();

      if (!mounted) return;

      final primary = Theme.of(context).colorScheme.primary;

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: primary,
          handleColor: primary,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white12,
        ),
        placeholder: Container(
          color: const Color(0xFF1a1a2e),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (ctx, errorMessage) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              AppSpacing.vGap8,
              Text('Không thể tải video\n$errorMessage',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e, st) {
      debugPrint('Video init error: $e\n$st');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: const Color(0xFF1a1a2e),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                AppSpacing.vGap8,
                Text('Lỗi: $_error', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        color: const Color(0xFF1a1a2e),
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }
}
