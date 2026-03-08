import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/core/utils/view_state.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/services/catalog_service.dart';

class VideoDetailViewModel extends ChangeNotifier {
  VideoDetailViewModel(this.service);

  final CatalogService service;

  ViewState<VideoItemModel> _viewState = ViewState.loading();
  ViewState<VideoItemModel> get viewState => _viewState;

  String? _currentVideoId;

  Future<void> fetchVideo(String videoId) async {
    if (_currentVideoId == videoId && _viewState.valueOrNull != null) {
      return;
    }

    _currentVideoId = videoId;
    _viewState = ViewState.loading();
    notifyListeners();

    final result = await service.fetchContentDetail(videoId);
    switch (result) {
      case Success<VideoItemModel>():
        _viewState = ViewState.success(result.data);
      case Failure<VideoItemModel>():
        _viewState = ViewState.error(result.message);
    }

    notifyListeners();
  }
}
