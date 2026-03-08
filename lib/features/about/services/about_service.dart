import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_client.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';
import 'package:surdotv_app/core/utils/html_utils.dart';
import 'package:surdotv_app/core/utils/result.dart';

class AboutService {
  AboutService(this.apiClient);

  final ApiClient apiClient;

  Future<Result<String>> fetchAboutText() async {
    try {
      final json = await apiClient.get(ApiConstants.endpointAbout)
          as Map<String, dynamic>;
      final content = htmlToPlainText((json['metn'] ?? '').toString());
      return Success(content);
    } on ApiException catch (error) {
      return Failure(error.userMessage, statusCode: error.statusCode);
    } catch (_) {
      return const Failure(kGenericErrorMessage);
    }
  }
}
