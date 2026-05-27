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
    // 保留当前 tab 与相邻 tab，避免频繁销毁重建
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

final activeVideoIdProvider =
    NotifierProvider<ActiveVideoIdNotifier, String?>(ActiveVideoIdNotifier.new);

class ActiveVideoIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}