import 'dart:convert';

import 'package:http/http.dart' as http;

/// Shared HTTP client for API calls. Holds access token, supports refresh on 401.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.onRefreshToken,
  });

  final String baseUrl;
  final Future<String?> Function() onRefreshToken;

  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  String _url(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '$base$p';
  }

  Map<String, String> _headers({bool auth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-correlation-id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    if (auth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    return _requestWithRefresh(() async {
      final res = await http.get(
        Uri.parse(_url(path)),
        headers: _headers(auth: auth),
      );
      return _handleResponse(res);
    }, auth);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _requestWithRefresh(() async {
      final res = await http.post(
        Uri.parse(_url(path)),
        headers: _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(res);
    }, auth);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _requestWithRefresh(() async {
      final res = await http.patch(
        Uri.parse(_url(path)),
        headers: _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(res);
    }, auth);
  }

  Future<void> delete(String path, {bool auth = true}) async {
    await _requestWithRefresh(() async {
      final res = await http.delete(
        Uri.parse(_url(path)),
        headers: _headers(auth: auth),
      );
      _handleResponse(res);
      return <String, dynamic>{};
    }, auth);
  }

  Future<T> _requestWithRefresh<T>(Future<T> Function() fn, bool auth) async {
    try {
      return await fn();
    } on ApiException catch (e) {
      if (auth && e.code == 'AUTH_UNAUTHORIZED') {
        final newToken = await onRefreshToken();
        if (newToken != null) {
          _accessToken = newToken;
          return await fn();
        }
      }
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    final body = res.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final error = body['error'] as Map<String, dynamic>?;
    final code = error?['code'] as String? ?? 'UNKNOWN';
    final message = error?['message'] as String? ?? 'Request failed';
    throw ApiException(code, message);
  }
}

class ApiException implements Exception {
  ApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}
