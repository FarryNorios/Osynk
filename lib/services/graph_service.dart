import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/enums.dart';
import 'graph_api.dart';

export 'graph_api.dart' show GraphResponse;

class GraphService implements GraphApi {
  final Future<String?> Function() getToken;

  GraphService({required this.getToken});

  // ─── Generic HTTP ───

  Future<GraphResponse> get(String url, {Map<String, String>? headers, int timeout = 15}) {
    return _request(url, headers: headers, timeout: timeout);
  }

  Future<GraphResponse> post(String url, {Map<String, String>? headers, Object? body, int timeout = 15}) {
    return _request(url, headers: headers, body: body, isPost: true, timeout: timeout);
  }

  Future<GraphResponse> put(String url, {Map<String, String>? headers, Object? body, int timeout = 30}) {
    return _request(url, headers: headers, body: body, isPut: true, timeout: timeout);
  }

  // ─── Core request with retry ───

  Future<GraphResponse> _request(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool isPost = false,
    bool isPut = false,
    int retries = 3,
    int timeout = 15,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        late final http.Response response;
        final uri = Uri.parse(url);
        final duration = Duration(seconds: timeout);

        if (isPut) {
          response = await http.put(uri, headers: headers, body: body).timeout(duration);
        } else if (isPost) {
          response = await http.post(uri, headers: headers, body: body).timeout(duration);
        } else {
          response = await http.get(uri, headers: headers).timeout(duration);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.body.isEmpty) {
            if (attempt < retries) {
              await Future.delayed(Duration(seconds: attempt * 2));
              continue;
            }
            return GraphResponse(status: ResponseStatus.emptyResponse);
          }
          return GraphResponse(status: ResponseStatus.success, data: response.body);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          return GraphResponse(status: ResponseStatus.authError, data: 'Auth failed (${response.statusCode})');
        } else if (response.statusCode == 404) {
          return GraphResponse(status: ResponseStatus.notFound, data: 'Not found (404)');
        } else if (response.statusCode == 409) {
          // Conflict (e.g. folder already exists) — treat as success
          return GraphResponse(status: ResponseStatus.success, data: response.body);
        } else if (response.statusCode >= 500) {
          if (attempt < retries) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
          return GraphResponse(status: ResponseStatus.serverError, data: 'HTTP ${response.statusCode}');
        } else {
          return GraphResponse(status: ResponseStatus.serverError, data: 'HTTP ${response.statusCode}: ${response.body}');
        }
      } on TimeoutException {
        if (attempt < retries) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        return GraphResponse(status: ResponseStatus.timeout, data: 'Request timeout');
      } on SocketException {
        if (attempt < retries) {
          await Future.delayed(Duration(seconds: attempt * 3));
          continue;
        }
        return GraphResponse(status: ResponseStatus.networkError, data: 'Network error');
      } catch (e) {
        if (attempt < retries) {
          await Future.delayed(Duration(seconds: attempt * 2));
          continue;
        }
        return GraphResponse(status: ResponseStatus.networkError, data: 'Request error: $e');
      }
    }

    return GraphResponse(status: ResponseStatus.networkError, data: 'Request failed');
  }

  // ─── Authenticated requests ───

  Future<GraphResponse> _authedGet(String url, {int timeout = 15}) async {
    final token = await getToken();
    if (token == null) return GraphResponse(status: ResponseStatus.authError, data: 'Not logged in');
    return get(url, headers: {'Authorization': 'Bearer $token'}, timeout: timeout);
  }

  Future<GraphResponse> _authedPost(String url, {Object? body, int timeout = 15}) async {
    final token = await getToken();
    if (token == null) return GraphResponse(status: ResponseStatus.authError, data: 'Not logged in');
    return post(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: body, timeout: timeout);
  }

  Future<GraphResponse> _authedPut(String url, {Object? body, int timeout = 30}) async {
    final token = await getToken();
    if (token == null) return GraphResponse(status: ResponseStatus.authError, data: 'Not logged in');
    return put(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/octet-stream'}, body: body, timeout: timeout);
  }

  // ─── Graph API (implements GraphApi) ───

  @override
  Future<GraphResponse> graphList(String path) async {
    final normalized = GraphApi.normalizePath(path);
    if (normalized.isEmpty) {
      return _authedGet('https://graph.microsoft.com/v1.0/me/drive/root/children');
    }
    final escaped = Uri.encodeFull(normalized);
    return _authedGet('https://graph.microsoft.com/v1.0/me/drive/root:/$escaped:/children');
  }

  @override
  Future<bool> graphPathExists(String remotePath) async {
    final normalized = GraphApi.normalizePath(remotePath);
    final url = normalized.isEmpty
        ? 'https://graph.microsoft.com/v1.0/me/drive/root'
        : 'https://graph.microsoft.com/v1.0/me/drive/root:/${Uri.encodeFull(normalized)}:';
    final response = await _authedGet(url);
    if (response.isSuccess) return true;
    if (response.status == ResponseStatus.notFound) return false;
    debugPrint('Path check failed: ${response.data}');
    return false;
  }

  @override
  Future<GraphResponse> graphCreateFolder(String parentPath, String name) async {
    final normalized = GraphApi.normalizePath(parentPath);
    final url = normalized.isEmpty
        ? 'https://graph.microsoft.com/v1.0/me/drive/root/children'
        : 'https://graph.microsoft.com/v1.0/me/drive/root:/${Uri.encodeFull(normalized)}:/children';

    final body = jsonEncode({
      'name': name,
      'folder': {},
      '@microsoft.graph.conflictBehavior': 'replace',
    });

    return _authedPost(url, body: body);
  }

  @override
  Future<GraphResponse> graphUploadFile(String remotePath, List<int> bytes) async {
    final normalized = GraphApi.normalizePath(remotePath);
    final url = 'https://graph.microsoft.com/v1.0/me/drive/root:/${Uri.encodeFull(normalized)}:/content';
    return _authedPut(url, body: bytes, timeout: 30);
  }

  @override
  Future<List<int>> graphDownloadFile(String remotePath, {void Function(int bytesTransferred)? onProgress}) async {
    final normalized = GraphApi.normalizePath(remotePath);
    final url = 'https://graph.microsoft.com/v1.0/me/drive/root:/${Uri.encodeFull(normalized)}:/content';
    final token = await getToken();
    if (token == null) throw Exception('Not logged in');

    final client = http.Client();
    try {
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          final request = http.Request('GET', Uri.parse(url));
          request.headers['Authorization'] = 'Bearer $token';
          final streamedResponse = await client.send(request).timeout(const Duration(seconds: 30));

          if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
            throw Exception('Auth failed, please re-login');
          } else if (streamedResponse.statusCode == 404) {
            throw Exception('File not found: $remotePath');
          } else if (streamedResponse.statusCode >= 500 && attempt < 3) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          } else if (streamedResponse.statusCode != 200) {
            throw Exception('Download failed (HTTP ${streamedResponse.statusCode})');
          }

          // Stream response body with progress reporting
          final chunks = <List<int>>[];
          int received = 0;
          await for (final chunk in streamedResponse.stream) {
            chunks.add(chunk);
            received += chunk.length;
            onProgress?.call(received);
          }

          // Flatten chunks into single byte array
          final total = chunks.fold<int>(0, (sum, c) => sum + c.length);
          final result = Uint8List(total);
          int offset = 0;
          for (final chunk in chunks) {
            result.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }
          return result;
        } on TimeoutException {
          if (attempt < 3) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
          throw Exception('Download timeout: $remotePath');
        }
      }
      throw Exception('Download failed: $remotePath');
    } finally {
      client.close();
    }
  }

  @override
  Future<GraphResponse> getUserInfo() async {
    return _authedGet('https://graph.microsoft.com/v1.0/me');
  }

  @override
  Future<String?> exchangeCodeForRefreshToken(String authCode) async {
    final response = await post(
      'https://login.microsoftonline.com/common/oauth2/v2.0/token',
      body: {
        'client_id': GraphResponse.clientId,
        'code': authCode,
        'grant_type': 'authorization_code',
        'redirect_uri': GraphResponse.redirectUri,
      },
    );

    if (!response.isSuccess || response.data == null) {
      debugPrint('Failed to exchange auth code: ${response.status}');
      return null;
    }

    try {
      final tokenData = jsonDecode(response.data!) as Map<String, dynamic>;
      return tokenData['refresh_token'] as String?;
    } catch (e) {
      debugPrint('Failed to parse refresh token response: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshAccessToken(String refreshToken) async {
    final response = await post(
      'https://login.microsoftonline.com/common/oauth2/v2.0/token',
      body: {
        'client_id': GraphResponse.clientId,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      },
    );

    if (!response.isSuccess || response.data == null) {
      debugPrint('Token refresh failed: ${response.status}');
      return null;
    }

    try {
      final tokenData = jsonDecode(response.data!) as Map<String, dynamic>;
      return tokenData['access_token'] as String?;
    } catch (e) {
      debugPrint('Failed to parse access token response: $e');
      return null;
    }
  }
}
