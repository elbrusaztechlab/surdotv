import 'package:surdotv_app/core/config/app_env.dart';

class ApiConstants {
  ApiConstants._();

  static const String apiHost = 'api.surdotv.az';
  static const String uploadsBaseUrl = 'https://surdotv.az/uploads/';
  static const String bunnyEmbedBaseUrl =
      'https://iframe.mediadelivery.net/embed';

  static String get apiKey => AppEnv.surdoApiKey;

  static const String endpointHome = '/index';
  static const String endpointSections = '/sections';
  static const String endpointContent = '/content';
  static const String endpointAbout = '/about';
  static const String endpointRecommendedMovies = '/recommended-movies';
  static const String endpointSearch = '/search';
  static const String endpointSendMessage = '/send-message';
  static const String endpointAppVersion = '/app-version';

  static Uri buildUrl(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.https(
      apiHost,
      endpoint,
      queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  static String resolveImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '';
    }
    return '$uploadsBaseUrl${imagePath.trim()}';
  }

  static String buildBunnyEmbedUrl(String rawVideoPath) {
    final normalizedPath = normalizeBunnyVideoPath(rawVideoPath);
    return '$bunnyEmbedBaseUrl/$normalizedPath';
  }

  static String normalizeBunnyVideoPath(String rawVideoPath) {
    final trimmed = rawVideoPath.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(trimmed);
    final segments = uri?.pathSegments
            .where((segment) => segment.trim().isNotEmpty)
            .toList() ??
        trimmed
            .split('/')
            .where((segment) => segment.trim().isNotEmpty)
            .toList();

    if (segments.length >= 3) {
      final embedIndex = segments.indexOf('embed');
      if (embedIndex != -1 && segments.length > embedIndex + 2) {
        return '${segments[embedIndex + 1]}/${segments[embedIndex + 2]}';
      }

      final playIndex = segments.indexOf('play');
      if (playIndex != -1 && segments.length > playIndex + 2) {
        return '${segments[playIndex + 1]}/${segments[playIndex + 2]}';
      }
    }

    if (segments.length >= 2) {
      return '${segments[0]}/${segments[1]}';
    }

    return trimmed.replaceAll(RegExp(r'^/+|/+$'), '');
  }
}
