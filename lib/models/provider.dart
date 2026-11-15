class ProviderItem {
  final String slug;
  final String name;
  final String description;
  final bool isPublish;
  final bool needProxy;
  final bool needVpn;
  final String requiredCountryAccess;
  final int minRequiredBuild;

  ProviderItem({
    required this.slug,
    required this.name,
    required this.description,
    required this.isPublish,
    required this.needProxy,
    required this.needVpn,
    required this.requiredCountryAccess,
    required this.minRequiredBuild,
  });

  factory ProviderItem.fromJson(Map<String, dynamic> json) => ProviderItem(
        slug: json['slug'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        isPublish: json['is_publish'] as bool,
        needProxy: json['need_proxy'] as bool,
        needVpn: json['need_vpn'] as bool,
        requiredCountryAccess: json['required_country_access'] as String,
        minRequiredBuild: json['min_required_build'] as int,
      );
}

