import 'package:flutter_test/flutter_test.dart';

import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

void main() {
  group('VideoItemModel.playbackUrl', () {
    test('uses API video_url when it is already a direct URL', () {
      final model = VideoItemModel(
        id: '1',
        title: 'Sample',
        rawVideoUrl: 'https://cdn.example.com/video.mp4',
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

      expect(model.playbackUrl, 'https://cdn.example.com/video.mp4');
    });

    test('falls back to default mp4 when API still returns old numeric value', () {
      final model = VideoItemModel(
        id: '1',
        title: 'Sample',
        rawVideoUrl: '1110694207',
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

      expect(model.playbackUrl, ApiConstants.fallbackVideoUrl);
    });
  });
}
