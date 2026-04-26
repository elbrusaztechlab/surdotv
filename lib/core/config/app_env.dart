import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static String get surdoApiKey => _read(
        'SURDOTV_API_KEY',
      )!;

  static String? _read(String key, {String? fallback}) {
    final value = dotenv.isInitialized ? dotenv.maybeGet(key) : null;
    final trimmedValue = value?.trim();
    if (trimmedValue != null && trimmedValue.isNotEmpty) {
      return trimmedValue;
    }
    return fallback;
  }
}
