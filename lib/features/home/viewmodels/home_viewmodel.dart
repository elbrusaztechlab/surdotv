import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/core/utils/view_state.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/home/models/home_data_model.dart';
import 'package:surdotv_app/features/home/services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this.service);

  final HomeService service;

  ViewState<HomeDataModel> _viewState = ViewState.loading();
  ViewState<HomeDataModel> get viewState => _viewState;

  List<VideoItemModel> get sliderItems =>
      _viewState.valueOrNull?.sliderItems ?? [];
  List<CategoryModel> get featuredCategories =>
      _viewState.valueOrNull?.featuredCategories ?? [];

  Future<void> fetchHome() async {
    _viewState = ViewState.loading();
    notifyListeners();

    final result = await service.fetchHome();
    switch (result) {
      case Success<HomeDataModel>():
        _viewState = ViewState.success(result.data);
      case Failure<HomeDataModel>():
        _viewState = ViewState.error(result.message);
    }

    notifyListeners();
  }
}
