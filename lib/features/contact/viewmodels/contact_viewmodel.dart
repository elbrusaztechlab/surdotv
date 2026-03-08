import 'package:flutter/foundation.dart';

import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/contact/models/contact_message_model.dart';
import 'package:surdotv_app/features/contact/services/contact_service.dart';

class ContactViewModel extends ChangeNotifier {
  ContactViewModel(this.service);

  final ContactService service;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _submissionMessage;
  String? get submissionMessage => _submissionMessage;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  Future<void> submit(ContactMessageModel message) async {
    _isSubmitting = true;
    _submissionMessage = null;
    _isSuccess = false;
    notifyListeners();

    final result = await service.sendMessage(message);
    switch (result) {
      case Success<void>():
        _isSuccess = true;
        _submissionMessage = 'Mesajınız uğurla göndərildi.';
      case Failure<void>():
        _submissionMessage = result.message;
    }

    _isSubmitting = false;
    notifyListeners();
  }

  void clearFeedback() {
    _submissionMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}
