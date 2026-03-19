import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:surdotv_app/core/constants/api_constants.dart';
import 'package:surdotv_app/core/network/api_exceptions.dart';

class ApiClient {
  ApiClient(this._client, {this.timeout = const Duration(seconds: 30)});

  final http.Client _client;
  final Duration timeout;

  Map<String, String> get _defaultHeaders => {
        'Api-Key': ApiConstants.apiKey,
        'api_key': ApiConstants.apiKey,
      };

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = ApiConstants.buildUrl(
      endpoint,
      queryParameters: queryParameters,
    );

    try {
      final response = await _client
          .get(uri, headers: {..._defaultHeaders, ...?headers}).timeout(timeout,
              onTimeout: _throwTimeout);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<dynamic> postForm(
    String endpoint, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    final uri = ApiConstants.buildUrl(endpoint);

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              ..._defaultHeaders,
              ...?headers,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
            encoding: utf8,
          )
          .timeout(timeout, onTimeout: _throwTimeout);
      return _decodeResponse(response);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw _mapError(error);
    }
  }

  Never _throwTimeout() {
    throw ApiException('Request timeout', isNetworkError: true);
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  ApiException _mapError(Object error) {
    final isNetworkError = error is SocketException ||
        error is HandshakeException ||
        error.toString().toLowerCase().contains('socket');
    return ApiException(error.toString(), isNetworkError: isNetworkError);
  }
}
