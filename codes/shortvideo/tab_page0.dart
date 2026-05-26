import 'package:video/export.dart';
import 'package:video/main.dart';
import 'package:video/shortvideo/providers/tab0.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';
import 'package:video/shortvideo/video_feed_view.dart';

class VideoTabPage0 extends ConsumerStatefulWidget {
  final int index;
  const VideoTabPage0(this.index, {super.key});

  @override
  ConsumerState<VideoTabPage0> createState() => _VideoTabPage0State();
}

class _VideoTabPage0State extends ConsumerState<VideoTabPage0>
    with AutomaticKeepAliveClientMixin {
  bool _keepAlive = true;

  ProviderSubscription<Set<int>>? _keepAliveSub;
  ProviderSubscription<int>? _mainTabSub;
  ProviderSubscription<int>? _tabIndexSub;

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

    _mainTabSub = ref.listenManual(currentIndexProvider, (prev, next) {
      if (next != 1) {
        ref.read(activeVideoKeyProvider.notifier).set(null);
        return;
      }
      if (ref.read(videoTabIndexProvider) == widget.index) {
        _activateCurrentVideo();
      }
    });

    _tabIndexSub = ref.listenManual(videoTabIndexProvider, (prev, next) {
      if (next != widget.index) return;
      _activateCurrentVideo();
    });
  }

  void _activateCurrentVideo() {
    if (ref.read(videoTabIndexProvider) != widget.index) return;

    final videos = ref.read(shortVideoTab0Provider).value;
    final pageIndex = ref.read(videoPageTab0Provider);

    if (videos == null || videos.isEmpty) return;
    if (pageIndex < 0 || pageIndex >= videos.length) return;

    final key = makeActiveVideoKey(widget.index, videos[pageIndex].id);
    if (ref.read(activeVideoKeyProvider) != key) {
      ref.read(activeVideoKeyProvider.notifier).set(key);
    }
  }

  @override
  void dispose() {
    _keepAliveSub?.close();
    _mainTabSub?.close();
    _tabIndexSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncVideos = ref.watch(shortVideoTab0Provider);

    return asyncVideos.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(
            child: Text('暂无视频', style: TextStyle(color: Colors.white)),
          );
        }

        if (ref.read(videoTabIndexProvider) == widget.index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _activateCurrentVideo();
          });
        }

        final pageIndex = ref.read(videoPageTab0Provider).clamp(0, videos.length - 1);

        return VideoFeedView(
          tabIndex: widget.index,
          initialPage: pageIndex,
          videos: videos,
          onPageChanged: (index) {
            ref.read(videoPageTab0Provider.notifier).setIndex(index);
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (_, _) => Center(
        child: ElevatedButton(
          onPressed: () => ref.invalidate(shortVideoTab0Provider),
          child: const Text('重试'),
        ),
      ),
    );
  }
}