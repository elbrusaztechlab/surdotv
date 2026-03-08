import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/core/utils/view_state.dart';
import 'package:surdotv_app/features/about/services/about_service.dart';

class AboutViewModel extends ChangeNotifier {
  AboutViewModel(this.service);

  final AboutService service;

  ViewState<String> _viewState = ViewState.loading();
  ViewState<String> get viewState => _viewState;

  Future<void> fetchAbout() async {
    _viewState = ViewState.loading();
    notifyListeners();

    final result = await service.fetchAboutText();
    switch (result) {
      case Success<String>():
        _viewState = ViewState.success(result.data);
      case Failure<String>():
        _viewState = ViewState.error(result.message);
    }

    notifyListeners();
  }
}
