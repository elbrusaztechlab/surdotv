import 'dart:collection';

import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/models/paginated_items.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class CatalogService {
  CatalogService(this.apiClient);

  static const int defaultSectionPageLimit = 20;

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

  Future<Result<PaginatedItems<VideoItemModel>>> fetchSectionPage(
    String categoryId, {
    required int page,
    int limit = defaultSectionPageLimit,
  }) async {
    try {
      final json = await apiClient.get(
        '${ApiConstants.endpointSections}/$categoryId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      ) as Map<String, dynamic>;

      return Success(
        _parseVideoPage(
          json,
          page: page,
          limit: limit,
        ),
      );
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
        'limit': defaultSectionPageLimit,
      },
    ) as Map<String, dynamic>;

    final firstPageResult = _parseVideoPage(
      firstPage,
      page: 1,
      limit: defaultSectionPageLimit,
    );
    final firstPageVideos = firstPageResult.items;
    final totalPages = firstPageResult.totalPages;

    if (!fetchAllPages || totalPages <= 1) {
      return firstPageVideos;
    }

    final additionalPages = await Future.wait(
      List.generate(totalPages - 1, (index) => index + 2).map((page) async {
        final json = await apiClient.get(
          '${ApiConstants.endpointSections}/$categoryId',
          queryParameters: {
            'page': page,
            'limit': defaultSectionPageLimit,
          },
        ) as Map<String, dynamic>;
        return _parseVideoPage(
          json,
          page: page,
          limit: defaultSectionPageLimit,
        ).items;
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

  PaginatedItems<VideoItemModel> _parseVideoPage(
    Map<String, dynamic> json, {
    required int page,
    required int limit,
  }) {
    final currentPage = (json['page'] ?? json['current_page'] ?? page) is num
        ? ((json['page'] ?? json['current_page'] ?? page) as num).toInt()
        : page;
    final hasServerPaging =
        json['total_pages'] is num || json['last_page'] is num;
    final totalPages =
        (json['total_pages'] ?? json['last_page'] ?? currentPage) is num
            ? ((json['total_pages'] ?? json['last_page'] ?? currentPage) as num)
                .toInt()
            : currentPage;
    final items = _parseVideoList(json);
    final hasMore =
        hasServerPaging ? currentPage < totalPages : items.length >= limit;

    return PaginatedItems(
      items: items,
      page: currentPage,
      limit: limit,
      totalPages: totalPages,
      hasMore: hasMore,
    );
  }
}
