/// Model data untuk payload informasi update aplikasi
class AppUpdateData {
  final String latestVersionName;
  final int latestBuildNumber;
  final bool isForceUpdate;
  final String updateMessage;
  final String updateUrl;

  const AppUpdateData({
    required this.latestVersionName,
    required this.latestBuildNumber,
    required this.isForceUpdate,
    required this.updateMessage,
    required this.updateUrl,
  });

  factory AppUpdateData.fromJson(Map<String, dynamic> json) {
    return AppUpdateData(
      latestVersionName: json['latest_version_name'] as String? ?? '',
      latestBuildNumber: (json['latest_build_number'] as num?)?.toInt() ?? 0,
      isForceUpdate: json['is_force_update'] as bool? ?? false,
      updateMessage: json['update_message'] as String? ?? '',
      updateUrl: json['update_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version_name': latestVersionName,
      'latest_build_number': latestBuildNumber,
      'is_force_update': isForceUpdate,
      'update_message': updateMessage,
      'update_url': updateUrl,
    };
  }
}

/// Model response root untuk endpoint check update
class AppUpdateResponse {
  final AppUpdateData? data;
  final String message;
  final int status;

  const AppUpdateResponse({
    this.data,
    required this.message,
    required this.status,
  });

  factory AppUpdateResponse.fromJson(Map<String, dynamic> json) {
    return AppUpdateResponse(
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AppUpdateData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'message': message,
      'status': status,
    };
  }

  bool get isSuccess => status == 200 && data != null;
}

