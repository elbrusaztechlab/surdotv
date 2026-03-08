const String kNoInternetMessage =
    'İnternet bağlantısı qurulmadı. Zəhmət olmasa yenidən yoxlayın.';

const String kGenericErrorMessage =
    'Xəta baş verdi. Bir az sonra yenidən cəhd edin.';

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;
  final bool isNetworkError;

  String get userMessage =>
      isNetworkError ? kNoInternetMessage : kGenericErrorMessage;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
