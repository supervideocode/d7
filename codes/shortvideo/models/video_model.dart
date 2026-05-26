
class VideoModel {
  final String id;
  final String cover;
  final String src;
  final String content;

  const VideoModel({
    required this.id,
    required this.cover,
    required this.src,
    required this.content,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) => VideoModel(
        id: json['id'].toString(),
        cover: json['cover'] ?? '',
        src: json['src'] ?? '',
        content: json['content'] ?? '',
      );
}