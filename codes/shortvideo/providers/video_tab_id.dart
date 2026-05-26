import 'package:video/export.dart';

final videoTabIndexProvider =
    NotifierProvider<VideoTabIndexNotifier, int>(VideoTabIndexNotifier.new);

class VideoTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setVideoTabIndex(int value) => state = value;
}

final keepAliveVideoProvider =
    NotifierProvider<KeepAliveVideoNotifier, Set<int>>(KeepAliveVideoNotifier.new);

class KeepAliveVideoNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{0};

  void setKeepAliveVideo(int current, int old) {
    final next = <int>{current};
    if (current - 1 >= 0) next.add(current - 1);
    if (current + 1 <= 4) next.add(current + 1);
    state = next;
  }
}

final videoPageTab0Provider =
    NotifierProvider.autoDispose<VideoPageTab0Notifier, int>(
  VideoPageTab0Notifier.new,
);

class VideoPageTab0Notifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int value) => state = value;
}

final videoPageTab1Provider =
    NotifierProvider.autoDispose<VideoPageTab1Notifier, int>(
  VideoPageTab1Notifier.new,
);

class VideoPageTab1Notifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int value) => state = value;
}

final videoPageTab2Provider =
    NotifierProvider.autoDispose<VideoPageTab2Notifier, int>(
  VideoPageTab2Notifier.new,
);

class VideoPageTab2Notifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int value) => state = value;
}

/// 关键：把活跃视频标识从“纯videoId”升级为“tabIndex::videoId”，避免跨tab同id串播
String makeActiveVideoKey(int tabIndex, String videoId) => '$tabIndex::$videoId';

final activeVideoKeyProvider =
    NotifierProvider<ActiveVideoKeyNotifier, String?>(ActiveVideoKeyNotifier.new);

class ActiveVideoKeyNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? key) => state = key;
}