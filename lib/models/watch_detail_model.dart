/// Model data detail konten untuk halaman Watch / Pemutar Video
class WatchDetailData {
  final String id;
  final String title;
  final String description;
  final String schedule;
  final String status;
  final String type;
  final String thumbnail;
  final String manifest;
  final bool drm;
  final String kid;
  final String key;

  const WatchDetailData({
    required this.id,
    required this.title,
    required this.description,
    required this.schedule,
    required this.status,
    required this.type,
    required this.thumbnail,
    required this.manifest,
    required this.drm,
    required this.kid,
    required this.key,
  });

  factory WatchDetailData.fromJson(Map<String, dynamic> json) {
    return WatchDetailData(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: json['type'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      manifest: json['manifest'] as String? ?? '',
      drm: json['drm'] as bool? ?? false,
      kid: json['kid'] as String? ?? '',
      key: json['key'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'schedule': schedule,
      'status': status,
      'type': type,
      'thumbnail': thumbnail,
      'manifest': manifest,
      'drm': drm,
      'kid': kid,
      'key': key,
    };
  }
}

/// Model response root dari endpoint `BASE_URL/{provider_slug}/{id}`
class WatchDetailResponse {
  final WatchDetailData? data;
  final String message;
  final int status;
  final String title;

  const WatchDetailResponse({
    this.data,
    required this.message,
    required this.status,
    required this.title,
  });

  factory WatchDetailResponse.fromJson(Map<String, dynamic> json) {
    return WatchDetailResponse(
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? WatchDetailData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'message': message,
      'status': status,
      'title': title,
    };
  }

  bool get isSuccess => status == 200 && data != null;
}

