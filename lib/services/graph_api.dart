import '../models/enums.dart';

// ─── Response types (shared by all adapters) ───

class GraphResponse {
  static const clientId = '83d66ca4-5e0b-424e-b08c-93aa50945d12';
  static const redirectUri = 'com.farry.osynk://auth';

  final ResponseStatus status;
  final String? data;

  GraphResponse({required this.status, this.data});

  bool get isSuccess => status == ResponseStatus.success;
}

// ─── Abstract interface ───

abstract class GraphApi {
  /// List children of a remote directory
  Future<GraphResponse> graphList(String path);

  /// Check if a remote path exists
  Future<bool> graphPathExists(String remotePath);

  /// Create a folder under parentPath
  Future<GraphResponse> graphCreateFolder(String parentPath, String name);

  /// Upload file bytes to remotePath
  Future<GraphResponse> graphUploadFile(String remotePath, List<int> bytes);

  /// Download file bytes from remotePath, with optional byte-level progress callback
  Future<List<int>> graphDownloadFile(String remotePath, {void Function(int bytesTransferred)? onProgress});

  /// Get current user info
  Future<GraphResponse> getUserInfo();

  /// Exchange OAuth auth code for refresh token
  Future<String?> exchangeCodeForRefreshToken(String authCode);

  /// Refresh access token using refresh token
  Future<String?> refreshAccessToken(String refreshToken);

  /// Normalize a remote path (strip leading slashes, unify separators)
  static String normalizePath(String path) {
    return path.replaceAll(RegExp(r'^[\\/]+'), '').replaceAll(RegExp(r'[\\]+'), '/');
  }
}
