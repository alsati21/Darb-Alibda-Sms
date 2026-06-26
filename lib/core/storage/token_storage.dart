import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'session_token';

  Future<void> saveToken(String token) => _storage.write(key: _key, value: token);
  Future<String?> readToken() => _storage.read(key: _key);
  Future<void> deleteToken() => _storage.delete(key: _key);
}
