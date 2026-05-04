import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Shared HTTP client for API calls. Holds access token, supports refresh on 401.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.onRefreshToken,
    this.onUnauthorized,
  });

  final String baseUrl;
  final Future<String?> Function() onRefreshToken;
  final Future<void> Function()? onUnauthorized;

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

  /// Fetches raw bytes (e.g. PDF file). Does not parse as JSON.
  Future<List<int>> getBytes(String path, {bool auth = true}) async {
    return _requestWithRefresh(() async {
      final headers = <String, String>{
        'x-correlation-id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      if (auth && _accessToken != null) {
        headers['Authorization'] = 'Bearer $_accessToken';
      }
      final res = await http.get(
        Uri.parse(_url(path)),
        headers: headers,
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return res.bodyBytes;
      }
      final body = _decodeJsonObject(res.body);
      final dynamic errorRaw = body['error'];
      final error = errorRaw is Map<String, dynamic> ? errorRaw : null;
      final code = _asString(error?['code']) ?? 'UNKNOWN';
      final message =
          _asString(error?['message']) ??
          _asString(body['message']) ??
          'Request failed (${res.statusCode})';
      throw ApiException(code, message, body);
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

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _requestWithRefresh(() async {
      final res = await http.put(
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

  Future<Map<String, dynamic>> uploadFile(
    String path,
    String fieldName,
    String filePath, {
    bool auth = true,
    Map<String, String>? queryParams,
  }) async {
    return _requestWithRefresh(() async {
      var uri = Uri.parse(_url(path));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      final request = http.MultipartRequest('POST', uri);
      if (auth && _accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      request.headers['x-correlation-id'] =
          DateTime.now().millisecondsSinceEpoch.toString();
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
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

  Future<Map<String, dynamic>> deleteAndGetJson(
    String path, {
    bool auth = true,
  }) async {
    return _requestWithRefresh(() async {
      final res = await http.delete(
        Uri.parse(_url(path)),
        headers: _headers(auth: auth),
      );
      return _handleResponse(res);
    }, auth);
  }

  Future<T> _requestWithRefresh<T>(Future<T> Function() fn, bool auth) async {
    try {
      return await fn();
    } on SocketException {
      throw ApiException(
        'NETWORK_ERROR',
        'Cannot connect to server. Please check your internet or API server.',
      );
    } on http.ClientException {
      throw ApiException(
        'NETWORK_ERROR',
        'Cannot connect to server. Please check your internet or API server.',
      );
    } on ApiException catch (e) {
      if (auth && e.code == 'AUTH_UNAUTHORIZED') {
        final newToken = await onRefreshToken();
        if (newToken != null) {
          _accessToken = newToken;
          return await fn();
        }
        if (onUnauthorized != null) {
          await onUnauthorized!();
        }
      }
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    final body = _decodeJsonObject(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final dynamic errorRaw = body['error'];
    final error = errorRaw is Map<String, dynamic> ? errorRaw : null;
    final code = _asString(error?['code']) ?? 'UNKNOWN';
    final message =
        _asString(error?['message']) ??
        _asString(body['message']) ??
        'Request failed (${res.statusCode})';
    throw ApiException(code, message, body);
  }

  Map<String, dynamic> _decodeJsonObject(String raw) {
    if (raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      // Normalize non-object payloads (e.g. true / [] / "ok") so callers do not crash.
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      // Keep raw text in response payload for debugging unexpected upstream responses.
      return <String, dynamic>{'message': raw};
    }
  }

  String? _asString(Object? value) => value is String ? value : null;
}

class ApiException implements Exception {
  ApiException(this.code, this.message, [this.data]);

  final String code;
  final String message;
  /// Full error response body (e.g. contains existingReport for REPORT_DUPLICATE_DETECTED).
  final Map<String, dynamic>? data;

  @override
  String toString() => message;
}
