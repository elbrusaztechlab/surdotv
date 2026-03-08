import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class SearchService {
  SearchService(this.apiClient);

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

  Future<Result<List<VideoItemModel>>> search(String query) async {
    try {
      final json = await apiClient.get(
        ApiConstants.endpointSearch,
        queryParameters: {
          'keyword': query,
          'page': 1,
          'limit': 15,
        },
      ) as Map<String, dynamic>;

      final rawList = (json['videos'] ??
          json['video_list'] ??
          json['items'] ??
          const []) as List<dynamic>;

      final videos = rawList
          .whereType<Map<String, dynamic>>()
          .map(VideoItemModel.fromJson)
          .toList();

      return Success(videos);
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }
}
