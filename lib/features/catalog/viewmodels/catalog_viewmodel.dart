import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/models/paginated_items.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/core/utils/view_state.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/services/catalog_service.dart';

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel(this.service);

  static const int _sectionPageSize = CatalogService.defaultSectionPageLimit;

  final CatalogService service;

  ViewState<List<CategoryModel>> _viewState = ViewState.loading();
  ViewState<List<CategoryModel>> get viewState => _viewState;

  String _selectedSectionId = '';
  String get selectedSectionId => _selectedSectionId;

  List<VideoItemModel> _sectionVideos = const [];
  List<VideoItemModel> get sectionVideos => _sectionVideos;

  bool _isLoadingSectionVideos = false;
  bool get isLoadingSectionVideos => _isLoadingSectionVideos;

  bool _isLoadingMoreSectionVideos = false;
  bool get isLoadingMoreSectionVideos => _isLoadingMoreSectionVideos;

  bool _hasMoreSectionVideos = false;
  bool get hasMoreSectionVideos => _hasMoreSectionVideos;

  String? _sectionErrorMessage;
  String? get sectionErrorMessage => _sectionErrorMessage;

  String? _sectionLoadMoreErrorMessage;
  String? get sectionLoadMoreErrorMessage => _sectionLoadMoreErrorMessage;

  int _sectionPage = 0;
  int _sectionRequestId = 0;

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

  Future<void> loadSectionVideos(
    String sectionId, {
    bool refresh = false,
  }) async {
    final normalizedSectionId = sectionId.trim();
    if (normalizedSectionId.isEmpty) {
      _selectedSectionId = '';
      _sectionVideos = const [];
      _sectionErrorMessage = null;
      _sectionLoadMoreErrorMessage = null;
      _sectionPage = 0;
      _hasMoreSectionVideos = false;
      _isLoadingSectionVideos = false;
      _isLoadingMoreSectionVideos = false;
      notifyListeners();
      return;
    }

    if (!refresh &&
        _selectedSectionId == normalizedSectionId &&
        _sectionVideos.isNotEmpty) {
      return;
    }

    final requestId = ++_sectionRequestId;
    _selectedSectionId = normalizedSectionId;
    _sectionVideos = const [];
    _sectionErrorMessage = null;
    _sectionLoadMoreErrorMessage = null;
    _sectionPage = 0;
    _hasMoreSectionVideos = false;
    _isLoadingSectionVideos = true;
    _isLoadingMoreSectionVideos = false;
    notifyListeners();

    final result = await service.fetchSectionPage(
      normalizedSectionId,
      page: 1,
      limit: _sectionPageSize,
    );

    if (requestId != _sectionRequestId) {
      return;
    }

    switch (result) {
      case Success<PaginatedItems<VideoItemModel>>():
        _sectionVideos = result.data.items;
        _sectionPage = result.data.page;
        _hasMoreSectionVideos = result.data.hasMore;
      case Failure<PaginatedItems<VideoItemModel>>():
        _sectionErrorMessage = result.message;
    }

    _isLoadingSectionVideos = false;
    notifyListeners();
  }

  Future<void> loadMoreSectionVideos() async {
    if (_selectedSectionId.isEmpty ||
        _isLoadingSectionVideos ||
        _isLoadingMoreSectionVideos ||
        !_hasMoreSectionVideos) {
      return;
    }

    final requestId = _sectionRequestId;
    _isLoadingMoreSectionVideos = true;
    _sectionLoadMoreErrorMessage = null;
    notifyListeners();

    final result = await service.fetchSectionPage(
      _selectedSectionId,
      page: _sectionPage + 1,
      limit: _sectionPageSize,
    );

    if (requestId != _sectionRequestId) {
      return;
    }

    switch (result) {
      case Success<PaginatedItems<VideoItemModel>>():
        _sectionVideos = _mergeUniqueVideos(_sectionVideos, result.data.items);
        _sectionPage = result.data.page;
        _hasMoreSectionVideos = result.data.hasMore;
      case Failure<PaginatedItems<VideoItemModel>>():
        _sectionLoadMoreErrorMessage = result.message;
    }

    _isLoadingMoreSectionVideos = false;
    notifyListeners();
  }

  Future<void> refreshSelectedSectionVideos() async {
    if (_selectedSectionId.isEmpty) {
      return;
    }
    await loadSectionVideos(_selectedSectionId, refresh: true);
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

  List<VideoItemModel> _mergeUniqueVideos(
    List<VideoItemModel> existing,
    List<VideoItemModel> incoming,
  ) {
    final videosById = <String, VideoItemModel>{};
    for (final video in existing) {
      videosById.putIfAbsent(video.id, () => video);
    }
    for (final video in incoming) {
      videosById.putIfAbsent(video.id, () => video);
    }
    return videosById.values.toList();
  }
}
