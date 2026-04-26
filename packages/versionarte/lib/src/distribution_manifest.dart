import 'package:flutter/foundation.dart';

class DistributionManifest {
  const DistributionManifest({
    this.android,
    this.iOS,
    this.macOS,
    this.windows,
    this.linux,
  });

  factory DistributionManifest.fromJson(Map<String, dynamic> json) {
    return DistributionManifest(
      android: _platformInfoFromJson(json['android']),
      iOS: _platformInfoFromJson(json['iOS'] ?? json['ios']),
      macOS: _platformInfoFromJson(json['macOS'] ?? json['macos']),
      windows: _platformInfoFromJson(json['windows']),
      linux: _platformInfoFromJson(json['linux']),
    );
  }

  final PlatformDistributionInfo? android;
  final PlatformDistributionInfo? iOS;
  final PlatformDistributionInfo? macOS;
  final PlatformDistributionInfo? windows;
  final PlatformDistributionInfo? linux;

  PlatformDistributionInfo? get currentPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => iOS,
      TargetPlatform.macOS => macOS,
      TargetPlatform.windows => windows,
      TargetPlatform.linux => linux,
      _ => null,
    };
  }

  Map<TargetPlatform, String?> get downloadUrls {
    return {
      TargetPlatform.android: android?.downloadUrl,
      TargetPlatform.iOS: iOS?.downloadUrl,
      TargetPlatform.macOS: macOS?.downloadUrl,
      TargetPlatform.windows: windows?.downloadUrl,
      TargetPlatform.linux: linux?.downloadUrl,
    };
  }

  String? getMessageForLanguage(String code) {
    return currentPlatform?.status.getMessageForLanguage(code);
  }

  Map<String, dynamic> toJson() {
    return {
      'android': android?.toJson(),
      'iOS': iOS?.toJson(),
      'macOS': macOS?.toJson(),
      'windows': windows?.toJson(),
      'linux': linux?.toJson(),
    };
  }

  static PlatformDistributionInfo? _platformInfoFromJson(Object? value) {
    if (value is! Map || value.isEmpty) {
      return null;
    }

    return PlatformDistributionInfo.fromJson(Map<String, dynamic>.from(value));
  }
}

class PlatformDistributionInfo {
  const PlatformDistributionInfo({
    required this.version,
    required this.status,
    this.downloadUrl,
  });

  factory PlatformDistributionInfo.fromJson(Map<String, dynamic> json) {
    return PlatformDistributionInfo(
      version: VersionDetails.fromJson(
        Map<String, dynamic>.from(json['version'] as Map),
      ),
      downloadUrl: json['download_url'] as String?,
      status: StatusDetails.fromJson(
        Map<String, dynamic>.from(json['status'] as Map),
      ),
    );
  }

  final VersionDetails version;
  final String? downloadUrl;
  final StatusDetails status;

  Map<String, dynamic> toJson() {
    return {
      'version': version.toJson(),
      'download_url': downloadUrl,
      'status': status.toJson(),
    };
  }
}

class VersionDetails {
  const VersionDetails({
    required this.minimum,
    required this.latest,
  });

  factory VersionDetails.fromJson(Map<String, dynamic> json) {
    return VersionDetails(
      minimum: json['minimum'].toString(),
      latest: json['latest'].toString(),
    );
  }

  final String minimum;
  final String latest;

  Map<String, dynamic> toJson() {
    return {
      'minimum': minimum,
      'latest': latest,
    };
  }
}

class StatusDetails {
  const StatusDetails({
    required this.active,
    this.message,
  });

  factory StatusDetails.fromJson(Map<String, dynamic> json) {
    final rawMessage = json['message'];
    return StatusDetails(
      active: json['active'] == true,
      message: rawMessage is Map
          ? rawMessage.map((key, value) => MapEntry(key.toString(), value))
          : null,
    );
  }

  final bool active;
  final Map<String, dynamic>? message;

  String? getMessageForLanguage(String code) {
    final value = message?[code];
    return value?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'message': message,
    };
  }
}
