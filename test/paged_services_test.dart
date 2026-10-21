import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/services/catalog_service.dart';
import 'package:surdotv_app/features/search/services/search_service.dart';

Map<String, dynamic> _video(int id, {bool hasVideo = true}) => {
      'id': id,
      'video_head': 'Video $id',
      'video_url': hasVideo ? '663712/uuid-$id' : '663712/video-yoxdur',
      'video_url2': hasVideo
          ? 'https://video.eee.az/play/uuid-$id'
          : 'https://video.eee.az/play/video-yoxdur',
    };

/// Serves `pages[page - 1]` under [listKey], with server paging fields.
ApiClient _clientFor(
  List<List<Map<String, dynamic>>> pages, {
  required String listKey,
  List<int>? requestedPages,
}) {
  return ApiClient(
    MockClient((request) async {
      final page = int.parse(request.url.queryParameters['page'] ?? '1');
      requestedPages?.add(page);
      return http.Response(
        jsonEncode({
          listKey: pages[page - 1],
          'current_page': page,
          'total_pages': pages.length,
          'per_page': 15,
        }),
        200,
      );
    }),
  );
}

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'SURDOTV_API_KEY=test');
  });

  group('CatalogService.fetchSectionPage', () {
    test('drops videos without a video', () async {
      final service = CatalogService(
        _clientFor([
          [_video(1), _video(2, hasVideo: false), _video(3)],
        ], listKey: 'video_list'),
      );

      final result = await service.fetchSectionPage('8', page: 1);

      final data = (result as Success).data;
      expect(data.items.map((video) => video.id), ['1', '3']);
      expect(data.hasMore, isFalse);
    });

    test('skips a page that is empty after filtering', () async {
      final requested = <int>[];
      final service = CatalogService(
        _clientFor(
          [
            [_video(1)],
            [_video(2, hasVideo: false), _video(3, hasVideo: false)],
            [_video(4)],
            [_video(5)],
          ],
          listKey: 'video_list',
          requestedPages: requested,
        ),
      );

      final result = await service.fetchSectionPage('8', page: 2);

      final data = (result as Success).data;
      expect(requested, [2, 3]);
      expect(data.items.map((video) => video.id), ['4']);
      expect(data.page, 3);
      expect(data.hasMore, isTrue);
    });

    test('returns empty without looping when the last page is empty',
        () async {
      final requested = <int>[];
      final service = CatalogService(
        _clientFor(
          [
            [_video(1)],
            [_video(2, hasVideo: false)],
          ],
          listKey: 'video_list',
          requestedPages: requested,
        ),
      );

      final result = await service.fetchSectionPage('8', page: 2);

      final data = (result as Success).data;
      expect(requested, [2]);
      expect(data.items, isEmpty);
      expect(data.hasMore, isFalse);
    });
  });

  group('SearchService.search', () {
    test('skips a page that is empty after filtering', () async {
      final requested = <int>[];
      final service = SearchService(
        _clientFor(
          [
            [_video(1, hasVideo: false)],
            [_video(2)],
          ],
          listKey: 'videos',
          requestedPages: requested,
        ),
      );

      final result = await service.search('x', page: 1);

      final data = (result as Success).data;
      expect(requested, [1, 2]);
      expect(data.items.map((video) => video.id), ['2']);
      expect(data.page, 2);
      expect(data.hasMore, isFalse);
    });

    test('sends limit 15', () async {
      final limits = <String?>[];
      final service = SearchService(
        ApiClient(
          MockClient((request) async {
            limits.add(request.url.queryParameters['limit']);
            return http.Response(jsonEncode({'videos': []}), 200);
          }),
        ),
      );

      await service.search('x', page: 1);

      expect(limits, ['15']);
    });
  });
}
