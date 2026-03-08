import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/result.dart';
import 'package:surdotv_app/features/contact/models/contact_message_model.dart';

class ContactService {
  ContactService(this.apiClient);

  final ApiClient apiClient;

  Future<Result<void>> sendMessage(ContactMessageModel message) async {
    try {
      await apiClient.postForm(
        ApiConstants.endpointSendMessage,
        body: message.toFormBody(),
        headers: message.toFormBody(),
      );
      return const Success<void>(null);
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }
}
