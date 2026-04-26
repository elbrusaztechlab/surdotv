import 'dart:async';

import 'package:versionarte/src/distribution_manifest.dart';

abstract class VersionarteProvider {
  const VersionarteProvider();

  FutureOr<DistributionManifest?> getDistributionManifest();
}
