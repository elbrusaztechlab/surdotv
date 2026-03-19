import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/utils/html_utils.dart';

class VideoItemModel {
  const VideoItemModel({
    required this.id,
    required this.title,
    required this.rawVideoUrl,
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
  });

  factory VideoItemModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return VideoItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['video_head'] ?? '').toString(),
      rawVideoUrl: (json['video_url'] ?? '').toString(),
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
    );
  }

  final String id;
  final String title;
  final String rawVideoUrl;
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

  String get imageUrl => ApiConstants.resolveImageUrl(imagePath);

  BunnyVideoSource? get bunnyVideoSource =>
      BunnyVideoSource.tryParse(rawVideoUrl);

  String get playbackUrl {
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

  String get shareText => '$title\n$playbackUrl';
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
