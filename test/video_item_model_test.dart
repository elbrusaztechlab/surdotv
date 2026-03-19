import 'package:flutter_test/flutter_test.dart';

import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

void main() {
  group('VideoItemModel.playbackUrl', () {
    test('uses direct URL when API already returns one', () {
      final model = _buildModel(
        rawVideoUrl: 'https://cdn.example.com/video.mp4',
      );

      expect(model.playbackUrl, 'https://cdn.example.com/video.mp4');
    });

    test('converts Bunny path to iframe embed URL', () {
      final model = _buildModel(
        rawVideoUrl: '614490/3712b0bb-8c8c-4659-b8bc-1f3328e777ec',
      );

      expect(
        model.playbackUrl,
        ApiConstants.buildBunnyEmbedUrl(
          '614490/3712b0bb-8c8c-4659-b8bc-1f3328e777ec',
        ),
      );
    });

    test('returns empty string when API returns empty string', () {
      final model = _buildModel(rawVideoUrl: '');

      expect(model.playbackUrl, '');
    });
  });
}

VideoItemModel _buildModel({
  required String rawVideoUrl,
}) {
  return VideoItemModel(
    id: '1',
    title: 'Sample',
    rawVideoUrl: rawVideoUrl,
    descriptionHtml: '',
    slug: '',
    shortText: '',
    ogTitle: '',
    ogKeywords: '',
    ogDescription: '',
    imagePath: '',
    viewCount: '',
    duration: '',
    publishedAt: '',
    categoryId: '',
    categoryName: '',
    parentCategoryId: '',
  );
}
