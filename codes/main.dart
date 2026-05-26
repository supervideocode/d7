import 'dart:ui';
import 'package:flutter/services.dart';
import 'export.dart';

final currentIndexProvider = NotifierProvider<CurrentIndexNotifier, int>(
  CurrentIndexNotifier.new,
);

class CurrentIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) {
    state = index;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 350;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 88 << 20;
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  //先挖5个坑
  final List<Widget?> _pages = [const Index(), null, null, null, null];

  @override
  void initState() {
    super.initState();
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return const ShortVideo();
      case 2:
        return const Vip();
      case 3:
        return const Organ();
      case 4:
        return const Home();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentIndexProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      sized: false,
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        //debugShowCheckedModeBanner: false,
        title: "SUPER短剧",
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          extendBody: true,
          body: IndexedStack(
            index: currentIndex,
            children: List.generate(
              5,
              (index) => _pages[index] ?? const SizedBox.shrink(),
            ),
          ),
          drawer: Drawer(
            backgroundColor: Colors.black38,
            child: Column(
              children: [
                DrawerHeader(
                  child: Text(
                    "头部",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: Container(
              clipBehavior: Clip.antiAlias,
              height: Sizes.bottomBarHeight,
              decoration: BoxDecoration(color: Colors.black54.withAlpha(100)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Row(
                  children: [
                    _item(
                      "首页",
                      "assets/index.png",
                      "assets/index_selected.png",
                      0,
                    ),
                    _item(
                      "短剧",
                      "assets/shortvideo.png",
                      "assets/shortvideo_selected.png",
                      1,
                    ),
                    _item("商城", "assets/vip.png", "assets/vip_selected.png", 2),
                    _item(
                      "社区",
                      "assets/organ.png",
                      "assets/organ_selected.png",
                      3,
                    ),
                    _item(
                      "我的",
                      "assets/home.png",
                      "assets/home_selected.png",
                      4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(String text, String image, String selectImage, int index) {
    final currentIndex = ref.watch(currentIndexProvider);
    final bool selected = currentIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white.withAlpha(30),
          highlightColor: Colors.white.withAlpha(50),
          onTap: () {
            if (currentIndex != index) {
              ref.read(currentIndexProvider.notifier).setIndex(index);
              _pages[index] ??= _buildPage(index);
            }
          },
          child: Column(
            spacing: 3,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                selected ? selectImage : image,
                width: 23,
                height: 23,
              ),
              Text(
                text,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : const Color.fromARGB(255, 176, 176, 176),
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                  shadows: selected
                      ? [
                          const Shadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 0,
                          ),
                        ]
                      : [
                          const Shadow(
                            color: Colors.white24,
                            offset: Offset(1, 1),
                            blurRadius: 0,
                          ),
                        ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
