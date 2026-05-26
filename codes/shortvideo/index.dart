import 'package:video/export.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';


class ShortVideo extends ConsumerStatefulWidget {
  const ShortVideo({super.key});

  @override
  ConsumerState<ShortVideo> createState() => _ShortVideoState();
}

class _ShortVideoState extends ConsumerState<ShortVideo>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;

  final List<String> tabs = const ["短视频", "短剧", "漫剧", "剧场", "福利"];

  int _pendingIndex = 0;
  bool _isHorizontalDragging = false;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _pageController = PageController(initialPage: 0);

    // 首次进入：触发tab0接管
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInit) return;
      _didInit = true;
      _commitTabFinal(0, initial: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _isOuterHorizontal(ScrollNotification n) =>
      n.depth == 0 && n.metrics.axis == Axis.horizontal;

  void _commitTabFinal(int newIndex, {bool initial = false}) {
    final oldIndex = ref.read(videoTabIndexProvider);
    if (!initial && newIndex == oldIndex) return;

    // 非首次切换：先清空当前播放key，避免老tab继续播
    if (!initial) {
      ref.read(activeVideoKeyProvider.notifier).set(null);
    }

    ref.read(videoTabIndexProvider.notifier).setVideoTabIndex(newIndex);
    ref.read(keepAliveVideoProvider.notifier).setKeepAliveVideo(newIndex, oldIndex);
  }

  Widget _buildTabPage(int index) {
    switch (index) {
      case 0:
        return const VideoTabPage0(0);
      case 1:
        return const VideoTabPage1(1);
      case 2:
        return const VideoTabPage2(2);
      case 3:
        return const VideoTabPage3(3);
      case 4:
        return const VideoTabPage4(4);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      color: Colors.black,
      child: Stack(
        children: [
          NotificationListener<ScrollStartNotification>(
            onNotification: (n) {
              if (!_isOuterHorizontal(n)) return false;
              _isHorizontalDragging = true;
              return false;
            },
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (n) {
                if (!_isOuterHorizontal(n)) return false;
                _isHorizontalDragging = false;
                _commitTabFinal(_pendingIndex); // 吸附完成才真正切播放归属
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: tabs.length,
                onPageChanged: (index) {
                  _pendingIndex = index;

                  // 你要的效果：tabbar尽早显示当前tab
                  _tabController.animateTo(index);

                  // 点击tab jumpToPage时的兜底
                  if (!_isHorizontalDragging) {
                    _commitTabFinal(index);
                  }
                },
                itemBuilder: (_, index) => _buildTabPage(index),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: Sizes.safeAreaAppend,
                left: Sizes.padding,
                right: Sizes.padding,
              ),
              child: TabBar(
                splashFactory: InkSparkle.splashFactory,
                padding: EdgeInsets.zero,
                dividerHeight: 0,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: Sizes.padding),
                tabAlignment: TabAlignment.start,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                indicator: const BoxDecoration(),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                isScrollable: true,
                controller: _tabController,
                onTap: (value) {
                  final current = ref.read(videoTabIndexProvider);
                  if (value == current) return;
                  _pendingIndex = value;
                  _pageController.jumpToPage(value);
                },
                tabs: tabs
                    .map(
                      (e) => Text(
                        e,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}