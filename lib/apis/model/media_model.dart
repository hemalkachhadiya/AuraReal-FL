// New Media class to handle the media object
class Media {
  final String? url;
  final int? type; // 0 for image, 1 for video, etc.

  Media({this.url, this.type});

  Media copyWith({String? url, int? type}) => Media(
    url: url ?? this.url,
    type: type ?? this.type,
  );

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      url: json['url'] as String?,
      type: json['type'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
    };
  }
}