import 'package:video/export.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';

class VideoTabPage3 extends ConsumerStatefulWidget {
  final int index;
  const VideoTabPage3(this.index, {super.key});

  @override
  ConsumerState<VideoTabPage3> createState() => _VideoTabPage3State();
}

class _VideoTabPage3State extends ConsumerState<VideoTabPage3>
    with AutomaticKeepAliveClientMixin {
  bool _keepAlive = true;
  @override
  bool get wantKeepAlive => _keepAlive;
  @override
  void initState() {
    super.initState();
    final currentSet = ref.read(keepAliveVideoProvider);
    _keepAlive = currentSet.contains(widget.index);
    ref.listenManual(keepAliveVideoProvider, (prev, next) {
      final shouldKeep = next.contains(widget.index);
      if (shouldKeep != _keepAlive) {
        _keepAlive = shouldKeep;
        updateKeepAlive();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AppBackground(
      color: Colors.black,
      child: Center(
        child: Text("PageView内容1", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
