/// Model data item konten dari provider slug
class ProviderContentItem {
  final String id;
  final String title;
  final String description;
  final String schedule;
  final String category;
  final String status;
  final String type;
  final bool hasImage;
  final String thumbnail;
  final int episodeCount;

  const ProviderContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.schedule,
    required this.category,
    required this.status,
    required this.type,
    required this.hasImage,
    required this.thumbnail,
    required this.episodeCount,
  });

  factory ProviderContentItem.fromJson(Map<String, dynamic> json) {
    return ProviderContentItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      hasImage: json['has_image'] as bool? ?? false,
      thumbnail: json['thumbnail'] as String? ?? '',
      episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'schedule': schedule,
      'category': category,
      'status': status,
      'type': type,
      'has_image': hasImage,
      'thumbnail': thumbnail,
      'episode_count': episodeCount,
    };
  }
}

/// Model response root untuk endpoint provider slug: BASE_URL/{slug}
class ProviderContentResponse {
  final List<ProviderContentItem> data;
  final String message;
  final int status;
  final String title;

  const ProviderContentResponse({
    required this.data,
    required this.message,
    required this.status,
    required this.title,
  });

  factory ProviderContentResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return ProviderContentResponse(
      data: rawList
          .map((e) => ProviderContentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
      'status': status,
      'title': title,
    };
  }

  bool get isSuccess => status == 200;
}

