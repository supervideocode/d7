import 'dart:convert';

import 'package:video/export.dart';
import 'package:video/shortvideo/models/video_model.dart';

final shortVideoTab0Provider =
    AsyncNotifierProvider.autoDispose<ShortVideoTab0Notifier, List<VideoModel>>(
      ShortVideoTab0Notifier.new,
    );

class ShortVideoTab0Notifier extends AsyncNotifier<List<VideoModel>> {
  final Request _request = Request();

  @override
  Future<List<VideoModel>> build() async {
    return _loadData();
  }

  Future<void> refreshData() async {
    state = await AsyncValue.guard(_loadData);
  }

  Future<List<VideoModel>> _loadData() async {
    final response = await _request.get("/request.php?mod=shortvideo");
    final data = jsonDecode(response) as Map<String, dynamic>;
    final list = (data['data'] ?? []) as List;
    return list
        .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
