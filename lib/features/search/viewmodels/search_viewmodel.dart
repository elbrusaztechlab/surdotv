import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/models/paginated_items.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/search/services/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this.service);

  final SearchService service;

  List<String> _recommendations = const [];
  List<String> get recommendations => _recommendations;

  List<VideoItemModel> _results = const [];
  List<VideoItemModel> get results => _results;

  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMoreResults = false;
  bool get hasMoreResults => _hasMoreResults;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _loadMoreErrorMessage;
  String? get loadMoreErrorMessage => _loadMoreErrorMessage;

  String? _recommendationsErrorMessage;
  String? get recommendationsErrorMessage => _recommendationsErrorMessage;

  String _lastQuery = '';
  String get lastQuery => _lastQuery;
  int _activeRequestId = 0;
  int _currentPage = 0;
  static const int _pageSize = SearchService.defaultPageLimit;

  Future<void> loadRecommendations() async {
    _isLoadingRecommendations = true;
    _recommendationsErrorMessage = null;
    notifyListeners();

    final result = await service.fetchRecommendations();
    switch (result) {
      case Success<List<String>>():
        _recommendations = result.data;
      case Failure<List<String>>():
        _recommendationsErrorMessage = result.message;
    }

    _isLoadingRecommendations = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();
    _lastQuery = normalizedQuery;
    if (normalizedQuery.isEmpty) {
      clearResults();
      return;
    }

    final requestId = ++_activeRequestId;
    _isSearching = true;
    _isLoadingMore = false;
    _errorMessage = null;
    _loadMoreErrorMessage = null;
    _results = const [];
    _currentPage = 0;
    _hasMoreResults = false;
    notifyListeners();

    final result = await service.search(
      normalizedQuery,
      page: 1,
      limit: _pageSize,
    );
    if (requestId != _activeRequestId) {
      return;
    }

    switch (result) {
      case Success<PaginatedItems<VideoItemModel>>():
        _results = result.data.items;
        _currentPage = result.data.page;
        _hasMoreResults = result.data.hasMore;
      case Failure<PaginatedItems<VideoItemModel>>():
        _errorMessage = result.message;
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_lastQuery.isEmpty ||
        _isSearching ||
        _isLoadingMore ||
        !_hasMoreResults) {
      return;
    }

    final requestId = _activeRequestId;
    final nextPage = _currentPage + 1;
    _isLoadingMore = true;
    _loadMoreErrorMessage = null;
    notifyListeners();

    final result = await service.search(
      _lastQuery,
      page: nextPage,
      limit: _pageSize,
    );

    if (requestId != _activeRequestId) {
      return;
    }

    switch (result) {
      case Success<PaginatedItems<VideoItemModel>>():
        _results = _mergeUniqueVideos(_results, result.data.items);
        _currentPage = result.data.page;
        _hasMoreResults = result.data.hasMore;
      case Failure<PaginatedItems<VideoItemModel>>():
        _loadMoreErrorMessage = result.message;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void clearResults() {
    _results = const [];
    _errorMessage = null;
    _loadMoreErrorMessage = null;
    _lastQuery = '';
    _activeRequestId++;
    _isSearching = false;
    _isLoadingMore = false;
    _currentPage = 0;
    _hasMoreResults = false;
    notifyListeners();
  }

  Future<void> retryLastSearch() async {
    if (_lastQuery.isEmpty) return;
    await search(_lastQuery);
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
