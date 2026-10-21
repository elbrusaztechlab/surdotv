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

    test('prefers video_url2 player page over Bunny path', () {
      final model = _buildModel(
        rawVideoUrl: '663712/e1ce2508-360b-4e99-9c7e-387584a272d5',
        playerPageUrl:
            'https://video.eee.az/play/e1ce2508-360b-4e99-9c7e-387584a272d5',
      );

      expect(
        model.playbackUrl,
        'https://video.eee.az/play/e1ce2508-360b-4e99-9c7e-387584a272d5',
      );
    });

    test('returns empty string for video-yoxdur placeholder', () {
      final model = _buildModel(
        rawVideoUrl: '663712/video-yoxdur',
        playerPageUrl: 'https://video.eee.az/play/video-yoxdur',
      );

      expect(model.hasVideo, isFalse);
      expect(model.playbackUrl, '');
    });
  });

  group('VideoItemModel.listFromJson', () {
    test('drops videos without a video file', () {
      final videos = VideoItemModel.listFromJson([
        {
          'id': 1,
          'video_url': '663712/abc',
          'video_url2': 'https://video.eee.az/play/abc',
        },
        {
          'id': 2,
          'video_url': '663712/video-yoxdur',
          'video_url2': 'https://video.eee.az/play/video-yoxdur',
        },
        {'id': 3, 'video_url': '', 'video_url2': ''},
      ]);

      expect(videos.map((video) => video.id), ['1']);
    });

    test('returns empty list for missing input', () {
      expect(VideoItemModel.listFromJson(null), isEmpty);
    });
  });

  group('VideoItemModel.fromJson', () {
    test('parses serial episodes and builds site page URL', () {
      final model = VideoItemModel.fromJson({
        'id': 95,
        'video_head': 'Mauqli 1-ci hissə ',
        'video_url': '663712/a',
        'video_url2': 'https://video.eee.az/play/a',
        'url': 'mauqli-1-ci-hisse--95',
        'category': {
          'id': 9,
          'name': 'Cizgi filmləri',
          'url': 'cizgi-filmleri/',
          'sub_id': '3',
        },
        'serial_episodes': [
          {'id': 95, 'video_url2': 'https://video.eee.az/play/a'},
          {'id': 96, 'video_url2': 'https://video.eee.az/play/b'},
          {'id': 97, 'video_url2': 'https://video.eee.az/play/video-yoxdur'},
        ],
      });

      expect(model.title, 'Mauqli 1-ci hissə');
      expect(model.serialEpisodes.map((video) => video.id), ['95', '96']);
      expect(
        model.webPageUrl,
        'https://surdotv.az/bolmeler/cizgi-filmleri/mauqli-1-ci-hisse--95/',
      );
    });
  });
}

VideoItemModel _buildModel({
  required String rawVideoUrl,
  String playerPageUrl = '',
}) {
  return VideoItemModel(
    id: '1',
    title: 'Sample',
    rawVideoUrl: rawVideoUrl,
    playerPageUrl: playerPageUrl,
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
    categorySlug: '',
    parentCategoryId: '',
  );
}
