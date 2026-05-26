import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video/shortvideo/models/video_model.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';
import 'package:video/shortvideo/video_item.dart';

class VideoFeedView extends ConsumerStatefulWidget {
  final int tabIndex;
  final int initialPage;
  final List<VideoModel> videos;
  final ValueChanged<int> onPageChanged;

  const VideoFeedView({
    super.key,
    required this.tabIndex,
    required this.initialPage,
    required this.videos,
    required this.onPageChanged,
  });

  @override
  ConsumerState<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends ConsumerState<VideoFeedView> {
  late PageController _pageController;
  late int _currentIndex;
  int _lastActivatedIndex = -1;

  @override
  void initState() {
    super.initState();
    final max = widget.videos.isEmpty ? 0 : widget.videos.length - 1;
    _currentIndex = widget.initialPage.clamp(0, max);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didUpdateWidget(covariant VideoFeedView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videos.isEmpty) return;
    final target = widget.initialPage.clamp(0, widget.videos.length - 1);

    final currentPage = _pageController.hasClients
        ? (_pageController.page ?? _currentIndex.toDouble()).round()
        : _currentIndex;

    if (_pageController.hasClients && target != currentPage) {
      _pageController.jumpToPage(target);
      _currentIndex = target;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isThisVerticalEnd(ScrollNotification n) =>
      n.depth == 0 && n.metrics.axis == Axis.vertical;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) {
        if (!_isThisVerticalEnd(n)) return false;
        if (!_pageController.hasClients || widget.videos.isEmpty) return false;
        if (ref.read(videoTabIndexProvider) != widget.tabIndex) return false;

        final page = (_pageController.page ?? _currentIndex.toDouble()).round();
        if (page < 0 || page >= widget.videos.length) return false;
        if (page == _lastActivatedIndex) return false;

        _lastActivatedIndex = page;
        _currentIndex = page;
        widget.onPageChanged(page);

        final key = makeActiveVideoKey(widget.tabIndex, widget.videos[page].id);
        ref.read(activeVideoKeyProvider.notifier).set(key);
        return false;
      },
      child: PageView.builder(
        key: PageStorageKey('feed_tab_${widget.tabIndex}'),
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          _currentIndex = index;
          widget.onPageChanged(index);
        },
        itemBuilder: (_, index) {
          final currentPage = _pageController.hasClients
              ? (_pageController.page ?? _currentIndex.toDouble()).round()
              : _currentIndex;

          final isActive = index == currentPage;
          final shouldPreload = (index - currentPage).abs() <= 1;

          return VideoItem(
            tabIndex: widget.tabIndex,
            video: widget.videos[index],
            isActive: isActive,
            shouldPreload: shouldPreload,
          );
        },
      ),
    );
  }
}