import 'package:flutter/foundation.dart';
import 'package:versionarte/src/distribution_manifest.dart';
import 'package:versionarte/src/versionarte_status.dart';

class VersionarteResult {
  const VersionarteResult(
    this.status, {
    this.manifest,
  });

  final VersionarteStatus status;
  final DistributionManifest? manifest;

  String? getMessageForLanguage(String code) {
    return manifest?.getMessageForLanguage(code);
  }

  Map<TargetPlatform, String?>? get downloadUrls {
    return manifest?.downloadUrls;
  }

  @override
  String toString() => 'VersionarteResult(status: $status)';
}
