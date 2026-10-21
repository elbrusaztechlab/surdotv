import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/utils/html_utils.dart';

class VideoItemModel {
  const VideoItemModel({
    required this.id,
    required this.title,
    required this.rawVideoUrl,
    required this.playerPageUrl,
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
    required this.categorySlug,
    required this.parentCategoryId,
    this.serialEpisodes = const [],
  });

  factory VideoItemModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return VideoItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['video_head'] ?? '').toString().trim(),
      rawVideoUrl: (json['video_url'] ?? '').toString(),
      playerPageUrl: (json['video_url2'] ?? '').toString(),
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
      categorySlug: (category?['url'] ?? '').toString(),
      parentCategoryId: (category?['sub_id'] ?? '').toString(),
      serialEpisodes: listFromJson(json['serial_episodes']),
    );
  }

  /// Parses a list of videos and drops the ones without a playable video.
  static List<VideoItemModel> listFromJson(dynamic rawList) {
    if (rawList is! List) {
      return const [];
    }
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(VideoItemModel.fromJson)
        .where((video) => video.hasVideo)
        .toList();
  }

  static const String _missingVideoMarker = 'video-yoxdur';

  final String id;
  final String title;
  final String rawVideoUrl;

  /// `video_url2`: our own player page (HLS with automatic Bunny fallback).
  final String playerPageUrl;
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
  final String categorySlug;
  final String parentCategoryId;

  /// Other episodes of the same serial; only filled by `/content/{id}`.
  final List<VideoItemModel> serialEpisodes;

  String get imageUrl => ApiConstants.resolveImageUrl(imagePath);

  bool get hasVideo {
    final urls = [rawVideoUrl.trim(), playerPageUrl.trim()]
        .where((url) => url.isNotEmpty)
        .toList();
    return urls.isNotEmpty &&
        !urls.any((url) => url.endsWith(_missingVideoMarker));
  }

  BunnyVideoSource? get bunnyVideoSource =>
      BunnyVideoSource.tryParse(rawVideoUrl);

  String get playbackUrl {
    if (!hasVideo) {
      return '';
    }

    final playerPageUri = Uri.tryParse(playerPageUrl.trim());
    if (playerPageUri != null &&
        (playerPageUri.scheme == 'http' || playerPageUri.scheme == 'https')) {
      return playerPageUri.toString();
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

  /// Page of this video on surdotv.az, e.g.
  /// `https://surdotv.az/bolmeler/senedli-filmler/bizim-kino-11--...-822/`.
  String get webPageUrl {
    final categoryPath = categorySlug.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    final videoPath = slug.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    if (categoryPath.isEmpty || videoPath.isEmpty) {
      return '';
    }
    return '${ApiConstants.siteBaseUrl}bolmeler/$categoryPath/$videoPath/';
  }

  String get shareText {
    final link = webPageUrl.isNotEmpty ? webPageUrl : playbackUrl;
    return link.isEmpty ? title : '$title\n$link';
  }
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
