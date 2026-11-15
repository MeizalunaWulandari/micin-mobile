import 'dart:ffi';

/// Helper untuk mendeteksi arsitektur ABI perangkat dan meresolusi link download APK secara dinamis.
class AbiHelper {
  AbiHelper._();

  /// Mengembalikan identifier ABI standar Android (contoh: arm64-v8a, armeabi-v7a, x86_64).
  static String getCurrentAbi() {
    try {
      final abi = Abi.current();
      switch (abi) {
        case Abi.androidArm:
          return 'armeabi-v7a';
        case Abi.androidArm64:
          return 'arm64-v8a';
        case Abi.androidX64:
          return 'x86_64';
        case Abi.androidIA32:
          return 'x86';
        case Abi.androidRiscv64:
          return 'riscv64';
        default:
          return 'arm64-v8a';
      }
    } catch (_) {
      return 'arm64-v8a';
    }
  }

  /// Meresolusi URL template APK dengan menggantikan placeholder `{abi}` dan `{version}`.
  /// Jika format URL hanya berupa nama file (misal `MicinProject_{abi}_{version}.apk`),
  /// otomatis diarahkan ke URL release GitHub aplikasi.
  static String resolveApkUrl(
    String urlTemplate, {
    required String versionName,
    String? overrideAbi,
    String githubReleaseBase =
        'https://github.com/MeizalunaWulandari/micin-mobile/releases/download',
  }) {
    if (urlTemplate.trim().isEmpty) return '';

    final abi = overrideAbi ?? getCurrentAbi();
    final version = versionName.isNotEmpty ? versionName : '1.0.0';

    var resolved = urlTemplate
        .replaceAll('{abi}', abi)
        .replaceAll('{version}', version);

    // Jika berupa nama file tanpa skema protokol http(s), sambungkan dengan URL release GitHub
    if (!resolved.startsWith('http://') && !resolved.startsWith('https://')) {
      final cleanBase = githubReleaseBase.endsWith('/')
          ? githubReleaseBase.substring(0, githubReleaseBase.length - 1)
          : githubReleaseBase;
      resolved = '$cleanBase/v$version/$resolved';
    }

    return resolved;
  }
}

