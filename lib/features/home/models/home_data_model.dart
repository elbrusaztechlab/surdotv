import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class HomeDataModel {
  const HomeDataModel({
    required this.sliderItems,
    required this.featuredCategories,
  });

  final List<VideoItemModel> sliderItems;
  final List<CategoryModel> featuredCategories;
}
