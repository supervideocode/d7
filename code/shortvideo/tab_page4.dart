import 'package:video/export.dart';
import 'package:video/shortvideo/providers/video_tab_id.dart';
class VideoTabPage4 extends ConsumerStatefulWidget {
  final int index;
  const VideoTabPage4(this.index,{super.key});

  @override
  ConsumerState<VideoTabPage4> createState() => _VideoTabPage4State();
}

class _VideoTabPage4State extends ConsumerState<VideoTabPage4> with AutomaticKeepAliveClientMixin{
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
    return AppBackground(color: Colors.black, child: Center(child: Text("PageView内容1",style: TextStyle(color: Colors.white),),));
  }
}