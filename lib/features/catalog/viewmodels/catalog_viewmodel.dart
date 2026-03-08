import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/core/utils/view_state.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/services/catalog_service.dart';

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel(this.service);

  final CatalogService service;

  ViewState<List<CategoryModel>> _viewState = ViewState.loading();
  ViewState<List<CategoryModel>> get viewState => _viewState;

  List<CategoryModel> get categories => _viewState.valueOrNull ?? const [];

  List<CategoryModel> get rootCategories =>
      categories.where((category) => category.isRoot).toList();

  List<VideoItemModel> get allVideos {
    final unique = <String, VideoItemModel>{};
    for (final category in categories) {
      for (final video in category.videos) {
        unique.putIfAbsent(video.id, () => video);
      }
    }
    return unique.values.toList();
  }

  Future<void> fetchCatalog() async {
    _viewState = ViewState.loading();
    notifyListeners();

    final result = await service.fetchCatalog();
    switch (result) {
      case Success<List<CategoryModel>>():
        _viewState = ViewState.success(result.data);
      case Failure<List<CategoryModel>>():
        _viewState = ViewState.error(result.message);
    }

    notifyListeners();
  }

  CategoryModel? categoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  VideoItemModel? findVideoById(String id) {
    try {
      return allVideos.firstWhere((video) => video.id == id);
    } catch (_) {
      return null;
    }
  }

  List<CategoryModel> childCategoriesOf(String categoryId) {
    return categories
        .where((category) => category.parentId == categoryId)
        .toList();
  }

  List<VideoItemModel> videosForCategory(String categoryId) {
    return service.collectVideosRecursively(
      categories: categories,
      categoryId: categoryId,
    );
  }

  List<VideoItemModel> similarVideos(String videoId, {int limit = 8}) {
    final currentVideo = findVideoById(videoId);
    if (currentVideo == null) {
      return allVideos.take(limit).toList();
    }

    final source = [
      ...videosForCategory(currentVideo.parentCategoryId.isNotEmpty
          ? currentVideo.parentCategoryId
          : currentVideo.categoryId),
      ...allVideos,
    ];

    final unique = <String, VideoItemModel>{};
    for (final video in source) {
      if (video.id == videoId) {
        continue;
      }
      unique.putIfAbsent(video.id, () => video);
      if (unique.length == limit) {
        break;
      }
    }
    return unique.values.toList();
  }
}
