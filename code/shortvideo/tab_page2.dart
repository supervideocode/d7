import 'package:video/export.dart';
import 'package:video/main.dart';
import 'package:video/shortvideo/providers/tab2.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';
import 'package:video/shortvideo/video_feed_view.dart';

class VideoTabPage2 extends ConsumerStatefulWidget {
  final int index;
  const VideoTabPage2(this.index, {super.key});

  @override
  ConsumerState<VideoTabPage2> createState() => _VideoTabPage2State();
}

class _VideoTabPage2State extends ConsumerState<VideoTabPage2>
    with AutomaticKeepAliveClientMixin {
  bool _keepAlive = true;
  ProviderSubscription<Set<int>>? _keepAliveSub;
  ProviderSubscription<int>? _tabIndexSub;
  ProviderSubscription<int>? _mainTabSub;

  @override
  bool get wantKeepAlive => _keepAlive;

  @override
  void initState() {
    super.initState();

    _keepAlive = ref.read(keepAliveVideoProvider).contains(widget.index);

    _keepAliveSub = ref.listenManual(keepAliveVideoProvider, (prev, next) {
      final shouldKeep = next.contains(widget.index);
      if (shouldKeep != _keepAlive) {
        _keepAlive = shouldKeep;
        updateKeepAlive();
      }
    });

    // 底部模块切换：离开短视频暂停，回来恢复当前页
    _mainTabSub = ref.listenManual(currentIndexProvider, (prev, next) {
      if (next != 1) {
        ref.read(activeVideoIdProvider.notifier).set(null);
        return;
      }
      _activateCurrentVideo();
    });

    // 短视频内部横向 tab 切换：切回 Tab2 时恢复当前页
    _tabIndexSub = ref.listenManual(videoTabIndexProvider, (prev, next) {
      if (next != widget.index) return;
      _activateCurrentVideo();
    });
  }

  void _activateCurrentVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final videos = ref.read(shortVideoTab2Provider).value;
      final pageIndex = ref.read(videoPageTab2Provider);
      if (videos != null && pageIndex >= 0 && pageIndex < videos.length) {
        ref.read(activeVideoIdProvider.notifier).set(videos[pageIndex].id);
      }
    });
  }

  @override
  void dispose() {
    _keepAliveSub?.close();
    _tabIndexSub?.close();
    _mainTabSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncVideos = ref.watch(shortVideoTab2Provider);

    return asyncVideos.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(
            child: Text('暂无视频', style: TextStyle(color: Colors.white)),
          );
        }

        // 首次进入短视频模块时，Tab2 第一个视频自动播
        final currentTab = ref.watch(videoTabIndexProvider);
        if (currentTab == widget.index) {
          final pageIndex = ref.read(videoPageTab2Provider);
          final target = (pageIndex >= 0 && pageIndex < videos.length)
              ? videos[pageIndex].id
              : videos.first.id;
          final active = ref.read(activeVideoIdProvider);
          if (active != target) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref.read(activeVideoIdProvider.notifier).set(target);
            });
          }
        }

        return VideoFeedView(
          videos: videos,
          onPageChanged: (index) {
            ref.read(videoPageTab2Provider.notifier).setIndex(index);
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, stack) => Center(
        child: ElevatedButton(
          onPressed: () => ref.invalidate(shortVideoTab2Provider),
          child: const Text('重试'),
        ),
      ),
    );
  }
}