import 'dart:convert';

import 'package:surdotv_app/features/app_update/services/app_update_service.dart';
import 'package:versionarte/versionarte.dart';

class AppVersionarteProvider extends VersionarteProvider {
  AppVersionarteProvider(this._appUpdateService);

  final AppUpdateService _appUpdateService;

  @override
  Future<DistributionManifest> getDistributionManifest() async {
    final manifestJson = await _appUpdateService.getDistributionManifestJson();
    return DistributionManifest.fromJson(
      jsonDecode(jsonEncode(manifestJson)) as Map<String, dynamic>,
    );
  }
}
