import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/home/models/home_data_model.dart';

class HomeService {
  HomeService(this.apiClient);

  final ApiClient apiClient;

  Future<Result<HomeDataModel>> fetchHome() async {
    try {
      final json = await apiClient.get(ApiConstants.endpointHome)
          as Map<String, dynamic>;

      final featuredCategories = <CategoryModel>[
        if (_mapFeaturedCategory(json['movies'] as Map<String, dynamic>?)
            case final category?)
          category,
        if (_mapFeaturedCategory(json['cartoons'] as Map<String, dynamic>?)
            case final category?)
          category,
      ];

      final sliderItems = ((json['sliderItems'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>())
          .map(VideoItemModel.fromJson)
          .toList();

      return Success(
        HomeDataModel(
          sliderItems: sliderItems,
          featuredCategories: featuredCategories,
        ),
      );
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }

  CategoryModel? _mapFeaturedCategory(Map<String, dynamic>? json) {
    if (json == null) return null;

    final videos = ((json['video_list'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>())
        .map(VideoItemModel.fromJson)
        .toList();

    return CategoryModel.fromJson(json, videos: videos);
  }
}
