import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static const String _legacySurdoApiKey =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String get surdoApiKey => _read(
        'SURDOTV_API_KEY',
        fallback: _legacySurdoApiKey,
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
