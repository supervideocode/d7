import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video/shortvideo/models/video_model.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';
import 'package:video/shortvideo/video_item.dart';

class VideoFeedView extends ConsumerStatefulWidget {
  final List<VideoModel> videos;
  final ValueChanged<int> onPageChanged;

  const VideoFeedView({
    super.key,
    required this.videos,
    required this.onPageChanged,
  });

  @override
  ConsumerState<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends ConsumerState<VideoFeedView> {
  late final PageController _pageController;
  int _currentIndex = 0;
  int _lastActivatedIndex = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (_) {
        if (!_pageController.hasClients || widget.videos.isEmpty) return false;

        final page = (_pageController.page ?? _currentIndex.toDouble()).round();
        if (page < 0 || page >= widget.videos.length) return false;
        if (page == _lastActivatedIndex) return false;

        _lastActivatedIndex = page;
        _currentIndex = page;
        widget.onPageChanged(page);
        ref.read(activeVideoIdProvider.notifier).set(widget.videos[page].id);
        return false;
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.videos.length,
        pageSnapping: true,
        onPageChanged: (index) {
          _currentIndex = index;
          widget.onPageChanged(index);
        },
        itemBuilder: (context, index) {
          final currentPage =
              _pageController.hasClients ? (_pageController.page ?? 0).round() : 0;
          final isActive = index == currentPage;
          final shouldPreload = (index - currentPage).abs() <= 1;

          return VideoItem(
            video: widget.videos[index],
            isActive: isActive,
            shouldPreload: shouldPreload,
          );
        },
      ),
    );
  }
}