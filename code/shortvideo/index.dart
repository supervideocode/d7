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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
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
          PageView.builder(
            controller: _pageController,
            itemCount: tabs.length,
            onPageChanged: (value) {
              final oldIndex = ref.read(videoTabIndexProvider);
              if (value == oldIndex) return;

              // 先暂停旧 tab 的视频，避免串播
              ref.read(activeVideoIdProvider.notifier).set(null);

              _tabController.animateTo(value);
              ref.read(videoTabIndexProvider.notifier).setVideoTabIndex(value);
              ref
                  .read(keepAliveVideoProvider.notifier)
                  .setKeepAliveVideo(value, oldIndex);
            },
            itemBuilder: (context, index) => _buildTabPage(index),
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
                  final oldIndex = ref.read(videoTabIndexProvider);
                  if (value == oldIndex) return;

                  // 点击 tab 直接跳转（按你的交互要求）
                  _pageController.jumpToPage(value);
                },
                tabs: List.generate(tabs.length, (index) {
                  return Text(
                    tabs[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}