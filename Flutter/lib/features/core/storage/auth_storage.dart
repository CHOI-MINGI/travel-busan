import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _nicknameKey = 'nickname';
  static const _isGuideKey = 'is_guide';

  // 토큰 저장
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 사용자 정보 저장
  static Future<void> saveUserData({
    required String userId,
    required String nickname,
    required bool isGuide,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _nicknameKey, value: nickname);
    await _storage.write(key: _isGuideKey, value: isGuide.toString());
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<String?> getNickname() async {
    return await _storage.read(key: _nicknameKey);
  }

  static Future<bool> isGuide() async {
    final value = await _storage.read(key: _isGuideKey);
    return value == 'true';
  }

  // 모든 정보 삭제 (로그아웃 시 사용)
  static Future<void> deleteAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _nicknameKey);
    await _storage.delete(key: _isGuideKey);
  }

  // 기존 deleteToken 대체용
  static Future<void> deleteToken() async {
    await deleteAuthData();
  }
}
