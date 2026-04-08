class WechatArticle {
  final int? id;
  final String? title;
  final String? description;
  final String? coverUrl;
  final String? articleUrl;
  final String? author;
  final String? publishTime;
  final String? source;

  WechatArticle({
    this.id,
    this.title,
    this.description,
    this.coverUrl,
    this.articleUrl,
    this.author,
    this.publishTime,
    this.source,
  });

  factory WechatArticle.fromJson(Map<String, dynamic> json) {
    return WechatArticle(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coverUrl: json['coverUrl'],
      articleUrl: json['articleUrl'],
      author: json['author'],
      publishTime: json['publishTime'],
      source: json['source'],
    );
  }
}
