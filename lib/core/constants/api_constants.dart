class ApiConstants {
  ApiConstants._();

  static const String apiHost = 'api.surdotv.az';
  static const String uploadsBaseUrl = 'https://surdotv.az/uploads/';
  static const String apiKey =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const String fallbackVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  static const String endpointHome = '/index';
  static const String endpointSections = '/sections';
  static const String endpointContent = '/content';
  static const String endpointAbout = '/about';
  static const String endpointRecommendedMovies = '/recommended-movies';
  static const String endpointSearch = '/search';
  static const String endpointSendMessage = '/send-message';

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
}
