import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/viewmodels/catalog_viewmodel.dart';
import 'package:surdotv_app/features/search/services/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this.service);

  final SearchService service;
  CatalogViewModel? _catalogViewModel;

  List<String> _recommendations = const [];
  List<String> get recommendations => _recommendations;

  List<VideoItemModel> _results = const [];
  List<VideoItemModel> get results => _results;

  bool _isLoadingRecommendations = false;
  bool get isLoadingRecommendations => _isLoadingRecommendations;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _recommendationsErrorMessage;
  String? get recommendationsErrorMessage => _recommendationsErrorMessage;

  String _lastQuery = '';
  String get lastQuery => _lastQuery;
  int _activeRequestId = 0;
  bool _isUsingLocalFallback = false;
  bool get isUsingLocalFallback => _isUsingLocalFallback;

  void updateCatalog(CatalogViewModel catalogViewModel) {
    _catalogViewModel = catalogViewModel;
  }

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
    _errorMessage = null;
    _isUsingLocalFallback = false;
    notifyListeners();

    final result = await service.search(normalizedQuery);
    if (requestId != _activeRequestId) {
      return;
    }

    switch (result) {
      case Success<List<VideoItemModel>>():
        _results = result.data;
        _isUsingLocalFallback = false;
      case Failure<List<VideoItemModel>>():
        final fallbackResults = _searchLocally(normalizedQuery);
        _results = fallbackResults;
        if (fallbackResults.isEmpty) {
          _isUsingLocalFallback = false;
          _errorMessage = result.message;
        } else {
          _isUsingLocalFallback = true;
        }
    }

    _isSearching = false;
    notifyListeners();
  }

  void clearResults() {
    _results = const [];
    _errorMessage = null;
    _lastQuery = '';
    _activeRequestId++;
    _isUsingLocalFallback = false;
    notifyListeners();
  }

  Future<void> retryLastSearch() async {
    if (_lastQuery.isEmpty) return;
    await search(_lastQuery);
  }

  List<VideoItemModel> _searchLocally(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final source = _catalogViewModel?.allVideos ?? const <VideoItemModel>[];
    return source.where((video) {
      final haystacks = [
        video.title,
        video.ogTitle,
        video.ogKeywords,
        video.ogDescription,
        video.plainDescription,
      ].map((item) => item.toLowerCase());

      return haystacks.any((item) => item.contains(normalizedQuery));
    }).toList();
  }
}
