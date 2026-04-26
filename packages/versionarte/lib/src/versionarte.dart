import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:versionarte/src/versionarte_provider.dart';
import 'package:versionarte/src/versionarte_result.dart';
import 'package:versionarte/src/versionarte_status.dart';

class Versionarte {
  Versionarte._();

  static Future<VersionarteResult> check({
    required VersionarteProvider versionarteProvider,
    bool silent = false,
    String? currentVersion,
  }) async {
    try {
      final manifest = await versionarteProvider.getDistributionManifest();
      final platformInfo = manifest?.currentPlatform;
      if (manifest == null || platformInfo == null) {
        return VersionarteResult(VersionarteStatus.unknown, manifest: manifest);
      }

      if (!platformInfo.status.active) {
        return VersionarteResult(VersionarteStatus.inactive, manifest: manifest);
      }

      final appVersion =
          currentVersion ?? (await PackageInfo.fromPlatform()).version;
      final current = _ComparableVersion.parse(appVersion);
      final minimum = _ComparableVersion.parse(platformInfo.version.minimum);
      final latest = _ComparableVersion.parse(platformInfo.version.latest);

      if (current.compareTo(minimum) < 0) {
        return VersionarteResult(
          VersionarteStatus.forcedUpdate,
          manifest: manifest,
        );
      }

      if (current.compareTo(latest) < 0) {
        return VersionarteResult(VersionarteStatus.outdated, manifest: manifest);
      }

      return VersionarteResult(VersionarteStatus.upToDate, manifest: manifest);
    } catch (error, stackTrace) {
      if (!silent) {
        debugPrint('Versionarte check failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      return const VersionarteResult(VersionarteStatus.unknown);
    }
  }

  static Future<void> launchDownloadUrl(
    Map<TargetPlatform, String?>? data,
  ) async {
    final url = data?[defaultTargetPlatform];
    if (url == null || url.trim().isEmpty) {
      return;
    }

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}

class _ComparableVersion implements Comparable<_ComparableVersion> {
  const _ComparableVersion(this.parts);

  factory _ComparableVersion.parse(String value) {
    final cleanValue = value.split('+').first.split('-').first;
    final parts = cleanValue
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();

    while (parts.length < 3) {
      parts.add(0);
    }

    return _ComparableVersion(parts);
  }

  final List<int> parts;

  @override
  int compareTo(_ComparableVersion other) {
    final maxLength = parts.length > other.parts.length
        ? parts.length
        : other.parts.length;

    for (var index = 0; index < maxLength; index++) {
      final left = index < parts.length ? parts[index] : 0;
      final right = index < other.parts.length ? other.parts[index] : 0;
      if (left != right) {
        return left.compareTo(right);
      }
    }

    return 0;
  }
}
