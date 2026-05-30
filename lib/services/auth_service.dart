import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enums.dart';
import 'graph_api.dart';

class AuthService {
  final GraphApi _graph;
  final _storage = const FlutterSecureStorage();

  String? _refreshToken;
  String? _accessToken;

  LoginStatus _status = LoginStatus.loading;
  LoginStatus get status => _status;

  String? _userName;
  String? get userName => _userName;

  String? _userEmail;
  String? get userEmail => _userEmail;

  void Function(LoginStatus status)? onStatusChanged;

  AuthService(this._graph);

  // ─── Token Management ───

  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    await _refreshAccessToken();
    return _accessToken;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  Future<void> _loadRefreshToken() async {
    _refreshToken = await _storage.read(key: 'refreshToken');
  }

  Future<void> _saveRefreshToken() async {
    if (_refreshToken == null) return;
    await _storage.write(key: 'refreshToken', value: _refreshToken);
  }

  Future<void> _deleteRefreshToken() async {
    _refreshToken = null;
    _accessToken = null;
    await _storage.delete(key: 'refreshToken');
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      await _loadRefreshToken();
    }
    if (_refreshToken == null) return;

    final accessToken = await _graph.refreshAccessToken(_refreshToken!);
    if (accessToken != null) {
      _accessToken = accessToken;
    } else {
      _setStatus(LoginStatus.loggedOut);
      await _deleteRefreshToken();
    }
  }

  // ─── Login / Logout ───

  void launchLogin() {
    if (_status == LoginStatus.loading) return;
    _setStatus(LoginStatus.loading);
  }

  Future<void> logout() async {
    _userName = null;
    _userEmail = null;
    _setStatus(LoginStatus.loggedOut);
    await _deleteRefreshToken();
  }

  Future<bool> exchangeCode(String code) async {
    _setStatus(LoginStatus.loading);
    _refreshToken = await _graph.exchangeCodeForRefreshToken(code);
    if (_refreshToken != null) {
      await _saveRefreshToken();
      await fetchUserInfo();
      return _status == LoginStatus.loggedIn;
    } else {
      _setStatus(LoginStatus.loggedOut);
      return false;
    }
  }

  Future<void> init() async {
    await fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final response = await _graph.getUserInfo();
      if (!response.isSuccess || response.data == null) {
        _setStatus(LoginStatus.loggedOut);
        return;
      }

      final userInfo = jsonDecode(response.data!) as Map<String, dynamic>;
      _userName = userInfo['displayName'] as String?;
      _userEmail = (userInfo['mail'] ?? userInfo['userPrincipalName']) as String?;
      _setStatus(LoginStatus.loggedIn);
    } catch (e) {
      debugPrint('Failed to fetch user info: $e');
      _setStatus(LoginStatus.loggedOut);
    }
  }

  void _setStatus(LoginStatus status) {
    _status = status;
    onStatusChanged?.call(status);
  }
}
