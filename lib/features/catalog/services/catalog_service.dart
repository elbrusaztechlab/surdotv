import 'dart:collection';

import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class CatalogService {
  CatalogService(this.apiClient);

  final ApiClient apiClient;

  Future<Result<List<CategoryModel>>> fetchCatalog() async {
    try {
      final rootJson = await apiClient.get(ApiConstants.endpointSections)
          as Map<String, dynamic>;
      final sectionList = ((rootJson['category']
              as Map<String, dynamic>?)?['sub_items'] as List<dynamic>? ??
          const []);

      final baseCategories = sectionList
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();

      final detailResults = await Future.wait(
        baseCategories.map((category) async {
          try {
            final videos = await _fetchSectionVideos(
              category.id,
              fetchAllPages: false,
            );
            return category.copyWith(videos: videos);
          } catch (_) {
            return category.copyWith(videos: const []);
          }
        }),
      );

      return Success(detailResults);
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }

  Future<Result<VideoItemModel>> fetchContentDetail(String videoId) async {
    try {
      final json = await apiClient.get(
        '${ApiConstants.endpointContent}/$videoId',
      ) as Map<String, dynamic>;
      return Success(VideoItemModel.fromJson(json));
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }

  List<VideoItemModel> collectVideosRecursively({
    required List<CategoryModel> categories,
    required String categoryId,
  }) {
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final queue = Queue<String>()..add(categoryId);
    final seen = <String>{};
    final videosById = <String, VideoItemModel>{};

    while (queue.isNotEmpty) {
      final currentId = queue.removeFirst();
      if (!seen.add(currentId)) {
        continue;
      }

      final current = categoryMap[currentId];
      if (current == null) {
        continue;
      }

      for (final video in current.videos) {
        videosById.putIfAbsent(video.id, () => video);
      }

      for (final child
          in categories.where((item) => item.parentId == currentId)) {
        queue.add(child.id);
      }
    }

    return videosById.values.toList();
  }

  Future<List<VideoItemModel>> _fetchSectionVideos(
    String categoryId, {
    required bool fetchAllPages,
  }) async {
    final firstPage = await apiClient.get(
      '${ApiConstants.endpointSections}/$categoryId',
      queryParameters: const {
        'page': 1,
        'limit': 15,
      },
    ) as Map<String, dynamic>;

    final firstPageVideos = _parseVideoList(firstPage);
    final totalPages = (firstPage['total_pages'] as num?)?.toInt() ?? 1;

    if (!fetchAllPages || totalPages <= 1) {
      return firstPageVideos;
    }

    final additionalPages = await Future.wait(
      List.generate(totalPages - 1, (index) => index + 2).map((page) async {
        final json = await apiClient.get(
          '${ApiConstants.endpointSections}/$categoryId',
          queryParameters: {
            'page': page,
            'limit': 15,
          },
        ) as Map<String, dynamic>;
        return _parseVideoList(json);
      }),
    );

    return [
      ...firstPageVideos,
      ...additionalPages.expand((items) => items),
    ];
  }

  List<VideoItemModel> _parseVideoList(Map<String, dynamic> json) {
    return ((json['video_list'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>())
        .map(VideoItemModel.fromJson)
        .toList();
  }
}
