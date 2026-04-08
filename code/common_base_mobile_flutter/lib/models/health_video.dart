class HealthVideo {
  final int id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? coverUrl;
  final String? uploader;
  final String? uploadTime;
  final String? source;

  HealthVideo({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.coverUrl,
    this.uploader,
    this.uploadTime,
    this.source,
  });

  factory HealthVideo.fromJson(Map<String, dynamic> json) {
    return HealthVideo(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      videoUrl: json['videoUrl'] ?? '',
      coverUrl: json['coverUrl'],
      uploader: json['uploader'],
      uploadTime: json['uploadTime'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'coverUrl': coverUrl,
      'uploader': uploader,
      'uploadTime': uploadTime,
      'source': source,
    };
  }
}
