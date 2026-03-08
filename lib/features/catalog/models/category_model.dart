import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.videos,
  });

  factory CategoryModel.fromJson(
    Map<String, dynamic> json, {
    List<VideoItemModel> videos = const [],
  }) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      slug: (json['url'] ?? '').toString(),
      parentId: (json['sub_id'] ?? '').toString(),
      videos: videos,
    );
  }

  final String id;
  final String name;
  final String slug;
  final String parentId;
  final List<VideoItemModel> videos;

  bool get isRoot => parentId == '3';

  CategoryModel copyWith({
    List<VideoItemModel>? videos,
  }) {
    return CategoryModel(
      id: id,
      name: name,
      slug: slug,
      parentId: parentId,
      videos: videos ?? this.videos,
    );
  }
}
