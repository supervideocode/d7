
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:video/shortvideo/models/video_model.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';

class VideoItem extends ConsumerStatefulWidget {
  final VideoModel video;
  final bool isActive;
  final bool shouldPreload;

  const VideoItem({
    super.key,
    required this.video,
    required this.isActive,
    required this.shouldPreload,
  });

  @override
  ConsumerState<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends ConsumerState<VideoItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isInitializing = false;
  ProviderSubscription<String?>? _activeSub;

  @override
  void initState() {
    super.initState();
    if (widget.isActive || widget.shouldPreload) {
      _initVideo();
    }
    _listenActive();
  }

  @override
  void didUpdateWidget(covariant VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.shouldPreload && widget.shouldPreload && _controller == null) {
      _initVideo();
    }

    // 离开活跃范围，释放资源
    if (!widget.shouldPreload && !widget.isActive && _controller != null) {
      _disposeController();
      return;
    }

    // 仅在活跃状态变化时切换播放
    if (oldWidget.isActive != widget.isActive &&
        _controller != null &&
        _isInitialized) {
      if (widget.isActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _activeSub?.close();
    _controller?.dispose();
    super.dispose();
  }

  void _listenActive() {
    _activeSub = ref.listenManual(activeVideoIdProvider, (prev, next) {
      if (_controller == null || !_isInitialized) return;
      if (next == widget.video.id) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    });
  }

  Future<void> _initVideo() async {
    if (_isInitializing || _controller != null) return;
    _isInitializing = true;
    try {
      _controller = VideoPlayerController.networkUrl(
        //Uri.parse(widget.video.src)
      Uri.parse("https://stream7.iqilu.com/10339/upload_transcode/202002/09/20200209105011F0zPoYzHry.mp4")
      );
      await _controller!.initialize();

      if (!mounted) return;
      setState(() => _isInitialized = true);

      final activeId = ref.read(activeVideoIdProvider);
      if (activeId == widget.video.id) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      _isInitializing = false;
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
    } else {
      _isInitialized = false;
      _hasError = false;
    }
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _controller?.dispose();
    _controller = null;
    _initVideo();
  }

  void _toggleMute() {
    if (_controller == null) return;
    final current = _controller!.value.volume;
    _controller!.setVolume(current > 0 ? 0 : 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!_isInitialized)
            Image.network(
              widget.video.cover,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
            ),

          if (_isInitialized && _controller != null) VideoPlayer(_controller!),

          if (_isInitialized &&
              _controller != null &&
              _controller!.value.isBuffering)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),

          if (_hasError)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    const Text('加载失败', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                if (_isInitialized && _controller != null)
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        _controller!.value.volume > 0
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                _actionButton(Icons.favorite, '1.2w'),
                const SizedBox(height: 20),
                _actionButton(Icons.comment, '342'),
                const SizedBox(height: 20),
                _actionButton(Icons.share, '分享'),
              ],
            ),
          ),

          Positioned(
            left: 16,
            right: 80,
            bottom: 80,
            child: Text(
              widget.video.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}