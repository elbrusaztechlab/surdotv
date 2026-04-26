import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_client.dart';

class AppUpdateService {
  AppUpdateService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getDistributionManifestJson() async {
    final response = await _apiClient.get(ApiConstants.endpointAppVersion);
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }

      return response;
    }

    throw FormatException(
      'Invalid ${ApiConstants.endpointAppVersion} response format',
      response,
    );
  }
}
