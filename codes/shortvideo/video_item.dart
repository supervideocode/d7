
        
  import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:video/shortvideo/models/video_model.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';

class VideoItem extends ConsumerStatefulWidget {
  final int tabIndex;
  final VideoModel video;
  final bool isActive;
  final bool shouldPreload;

  const VideoItem({
    super.key,
    required this.tabIndex,
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

  String get _selfKey => makeActiveVideoKey(widget.tabIndex, widget.video.id);

  @override
  void initState() {
    super.initState();
    if (widget.isActive || widget.shouldPreload) _initVideo();
    _activeSub = ref.listenManual(activeVideoKeyProvider, (_, next) {
      _syncByActive(next);
    });
  }

  @override
  void didUpdateWidget(covariant VideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.shouldPreload && widget.shouldPreload && _controller == null) {
      _initVideo();
    }

    if (!widget.shouldPreload && !widget.isActive && _controller != null) {
      _disposeController();
      return;
    }

    _syncByActive(ref.read(activeVideoKeyProvider));
  }

  void _syncByActive(String? activeKey) {
    if (_controller == null || !_isInitialized) return;
    if (activeKey == _selfKey) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
  }

  Future<void> _initVideo() async {
    if (_isInitializing || _controller != null) return;
    _isInitializing = true;
    try {
      _controller = VideoPlayerController.networkUrl(
        //Uri.parse(widget.video.src),
        Uri.parse("https://stream7.iqilu.com/10339/upload_transcode/202002/09/20200209105011F0zPoYzHry.mp4")
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _syncByActive(ref.read(activeVideoKeyProvider));
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      _isInitializing = false;
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  @override
  void dispose() {
    _activeSub?.close();
    _controller?.dispose();
    super.dispose();
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
          if (_hasError)
            const Center(
              child: Text('加载失败', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}