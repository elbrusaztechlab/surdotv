import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/models/paginated_items.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class SearchService {
  SearchService(this.apiClient);

  static const int defaultPageLimit = 20;

  final ApiClient apiClient;

  Future<Result<List<String>>> fetchRecommendations() async {
    try {
      final json = await apiClient.get(ApiConstants.endpointRecommendedMovies)
          as Map<String, dynamic>;
      final items = (json['items'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList();
      return Success(items);
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }

  Future<Result<PaginatedItems<VideoItemModel>>> search(
    String query, {
    required int page,
    int limit = defaultPageLimit,
  }) async {
    try {
      final json = await apiClient.get(
        ApiConstants.endpointSearch,
        queryParameters: {
          'keyword': query,
          'page': page,
          'limit': limit,
        },
      ) as Map<String, dynamic>;

      return Success(_parsePage(json, page: page, limit: limit));
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }

  PaginatedItems<VideoItemModel> _parsePage(
    Map<String, dynamic> json, {
    required int page,
    required int limit,
  }) {
    final rawList = (json['videos'] ??
        json['video_list'] ??
        json['items'] ??
        const []) as List<dynamic>;

    final videos = rawList
        .whereType<Map<String, dynamic>>()
        .map(VideoItemModel.fromJson)
        .toList();

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
    final hasMore =
        hasServerPaging ? currentPage < totalPages : videos.length >= limit;

    return PaginatedItems(
      items: videos,
      page: currentPage,
      limit: limit,
      totalPages: totalPages,
      hasMore: hasMore,
    );
  }
}
