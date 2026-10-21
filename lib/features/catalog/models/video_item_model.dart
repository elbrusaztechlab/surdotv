import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/utils/html_utils.dart';

class VideoItemModel {
  const VideoItemModel({
    required this.id,
    required this.title,
    required this.rawVideoUrl,
    required this.videoUrl2,
    required this.descriptionHtml,
    required this.slug,
    required this.shortText,
    required this.ogTitle,
    required this.ogKeywords,
    required this.ogDescription,
    required this.imagePath,
    required this.viewCount,
    required this.duration,
    required this.publishedAt,
    required this.categoryId,
    required this.categoryName,
    required this.parentCategoryId,
    required this.categorySlug,
    required this.serialName,
    required this.serialEpisodes,
  });

  factory VideoItemModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final serial = json['serial'] as Map<String, dynamic>?;

    return VideoItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['video_head'] ?? '').toString(),
      rawVideoUrl: (json['video_url'] ?? '').toString(),
      videoUrl2: (json['video_url2'] ?? '').toString(),
      descriptionHtml: (json['video_about'] ?? '').toString(),
      slug: (json['url'] ?? '').toString(),
      shortText: (json['short_metn'] ?? '').toString(),
      ogTitle: (json['og_title'] ?? '').toString(),
      ogKeywords: (json['og_keywords'] ?? '').toString(),
      ogDescription: (json['og_description'] ?? '').toString(),
      imagePath: (json['image'] ?? '').toString(),
      viewCount: (json['baxilib'] ?? '').toString(),
      duration: (json['zaman'] ?? '').toString(),
      publishedAt: (json['tarix'] ?? '').toString(),
      categoryId: (category?['id'] ?? json['sub_id'] ?? '').toString(),
      categoryName: (category?['name'] ?? '').toString(),
      parentCategoryId: (category?['sub_id'] ?? '').toString(),
      categorySlug: (category?['url'] ?? '').toString(),
      serialName: (serial?['name'] ?? '').toString(),
      serialEpisodes: parseList(json['serial_episodes']),
    );
  }

  /// Parses a raw video list and drops entries that have no playable video.
  static List<VideoItemModel> parseList(Object? rawList) {
    return ((rawList as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>())
        .map(VideoItemModel.fromJson)
        .where((video) => video.hasVideo)
        .toList();
  }

  static const String _noVideoMarker = 'video-yoxdur';
  static const String siteBaseUrl = 'https://surdotv.az/';

  final String id;
  final String title;
  final String rawVideoUrl;
  final String videoUrl2;
  final String descriptionHtml;
  final String slug;
  final String shortText;
  final String ogTitle;
  final String ogKeywords;
  final String ogDescription;
  final String imagePath;
  final String viewCount;
  final String duration;
  final String publishedAt;
  final String categoryId;
  final String categoryName;
  final String parentCategoryId;
  final String categorySlug;
  final String serialName;
  final List<VideoItemModel> serialEpisodes;

  String get imageUrl => ApiConstants.resolveImageUrl(imagePath);

  BunnyVideoSource? get bunnyVideoSource =>
      BunnyVideoSource.tryParse(rawVideoUrl);

  bool get hasVideo {
    final url1 = rawVideoUrl.trim();
    final url2 = videoUrl2.trim();
    if (url1.isEmpty && url2.isEmpty) return false;
    return !url1.endsWith(_noVideoMarker) && !url2.endsWith(_noVideoMarker);
  }

  String get playbackUrl {
    final url2 = videoUrl2.trim();
    final url2Uri = Uri.tryParse(url2);
    if (url2Uri != null &&
        (url2Uri.scheme == 'http' || url2Uri.scheme == 'https')) {
      return url2;
    }

    final bunnySource = bunnyVideoSource;
    if (bunnySource != null) {
      return bunnySource.embedUrl;
    }

    final url = rawVideoUrl.trim();
    final uri = Uri.tryParse(url);
    final isDirectUrl = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (isDirectUrl) {
      return url;
    }

    return '';
  }

  String get plainDescription => htmlToPlainText(descriptionHtml);

  /// Page on surdotv.az, e.g. https://surdotv.az/bolmeler/cizgi-filmleri/mauqli-1-ci-hisse--95/
  String get webPageUrl {
    final category = categorySlug.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    final page = slug.trim();
    if (category.isEmpty || page.isEmpty) return siteBaseUrl;
    return '${siteBaseUrl}bolmeler/$category/$page/';
  }

  String get shareText => '${title.trim()}\n$webPageUrl';
}

class BunnyVideoSource {
  const BunnyVideoSource({
    required this.libraryId,
    required this.videoId,
  });

  static BunnyVideoSource? tryParse(String rawValue) {
    final trimmedValue = rawValue.trim();
    if (trimmedValue.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmedValue);
    if (uri != null && uri.hasScheme) {
      final segments = uri.pathSegments
          .where((segment) => segment.trim().isNotEmpty)
          .toList();

      final embedIndex = segments.indexOf('embed');
      if (embedIndex != -1 && segments.length > embedIndex + 2) {
        return BunnyVideoSource(
          libraryId: segments[embedIndex + 1],
          videoId: segments[embedIndex + 2],
        );
      }

      final playIndex = segments.indexOf('play');
      if (playIndex != -1 && segments.length > playIndex + 2) {
        return BunnyVideoSource(
          libraryId: segments[playIndex + 1],
          videoId: segments[playIndex + 2],
        );
      }

      return null;
    }

    final parts = trimmedValue
        .split('/')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.length < 2) {
      return null;
    }

    return BunnyVideoSource(
      libraryId: parts[0],
      videoId: parts[1],
    );
  }

  final String libraryId;
  final String videoId;

  String get path => '$libraryId/$videoId';

  String get embedUrl => ApiConstants.buildBunnyEmbedUrl(path);
}
