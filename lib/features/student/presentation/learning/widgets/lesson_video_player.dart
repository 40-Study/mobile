import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:study/di/di_container.dart';
import 'package:study/features/auth/data/auth_storage.dart';
import 'package:study/theme/theme.dart';
import 'package:video_player/video_player.dart';

class LessonVideoPlayer extends StatefulWidget {
  const LessonVideoPlayer({
    super.key,
    this.videoUrl,
    this.onProgressThreshold,
    this.progressThreshold = 0.8,
  });
  final String? videoUrl;
  /// Called when threshold reached. Params: playedRanges, durationSeconds
  final void Function(List<List<int>> playedRanges, int durationSeconds)? onProgressThreshold;
  final double progressThreshold;

  @override
  State<LessonVideoPlayer> createState() => _LessonVideoPlayerState();
}

class _LessonVideoPlayerState extends State<LessonVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;
  bool _usedFallback = false;
  bool _thresholdTriggered = false;

  // Track played ranges
  final List<List<int>> _playedRanges = [];
  int? _currentRangeStart;
  bool _wasPlaying = false;

  // Fallback video khi URL chính lỗi
  static const _fallbackVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_videoController == null) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo({bool useFallback = false}) async {
    try {
      final url = useFallback
          ? _fallbackVideoUrl
          : (widget.videoUrl ?? _fallbackVideoUrl);

      // Only add auth headers for our API domain
      final headers = <String, String>{};
      final uri = Uri.parse(url);
      final isOurApi = uri.host.contains('40study') ||
          uri.host.contains('api.') ||
          uri.host.contains('localhost');

      if (isOurApi) {
        final authStorage = diContainer<AuthStorage>();
        final token = await authStorage.getAccessToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: headers,
      );
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

      // Listen progress để trigger callback khi đạt threshold
      controller.addListener(_onVideoProgress);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _usedFallback = useFallback;
        });
      }
    } catch (e) {
      // Try fallback nếu chưa dùng
      if (!useFallback && widget.videoUrl != null) {
        await _initializeVideo(useFallback: true);
        return;
      }

      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _onVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final durationMs = controller.value.duration.inMilliseconds;
    final positionMs = controller.value.position.inMilliseconds;
    if (durationMs <= 0) return;

    final isPlaying = controller.value.isPlaying;
    final positionSec = controller.value.position.inSeconds;

    // Track play/pause để build played ranges
    if (isPlaying && !_wasPlaying) {
      _currentRangeStart = positionSec;
    } else if (!isPlaying && _wasPlaying && _currentRangeStart != null) {
      _playedRanges.add([_currentRangeStart!, positionSec]);
      _currentRangeStart = null;
    }
    _wasPlaying = isPlaying;

    // Check threshold
    if (_thresholdTriggered) return;
    final progress = positionMs / durationMs;
    if (progress >= widget.progressThreshold) {
      _thresholdTriggered = true;
      // Close current range nếu đang play
      if (_currentRangeStart != null) {
        _playedRanges.add([_currentRangeStart!, positionSec]);
        _currentRangeStart = null;
      }
      widget.onProgressThreshold?.call(
        List.from(_playedRanges),
        controller.value.duration.inSeconds,
      );
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _error = null;
      _isInitialized = false;
      _usedFallback = false;
    });
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    _initializeVideo();
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
                const Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
                AppSpacing.vGap12,
                const Text(
                  'Không thể tải video',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                AppSpacing.vGap16,
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Thử lại'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white30),
                  ),
                ),
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
      child: Stack(
        children: [
          Chewie(controller: _chewieController!),
          // Banner khi dùng fallback video
          if (_usedFallback)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Video mẫu',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
