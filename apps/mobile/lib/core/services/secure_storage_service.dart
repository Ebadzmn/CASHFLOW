import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    // Delete specific keys just to be triple-sure (fixes potential OS Keychain glitches)
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    // Delete all data to ensure no auth state is left behind
    await _storage.deleteAll();
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    // More robust check: Ensure token is not null, not empty, and not just whitespace
    return token != null && token.trim().isNotEmpty;
  }
}
