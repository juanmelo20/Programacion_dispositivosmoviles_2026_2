import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:parcial_2/model/auth/user_model.dart';


class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // Llaves (key) con las que se guarda cada valor (value).
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: tokenKey, value: token);
    } catch (_) {
      
      await _storage.deleteAll(); // Se borra todo (token y usuario) si hay un error al guardar el token.
      await _storage.write(key: tokenKey, value: token); // Se vuelve a guardar el token después de borrar todo.
    }
  }

  //Borra el token guardado (logout o token vencido).
  Future<String?> readToken() async {
    try {
      return await _storage.read(key: tokenKey);
    } catch (_) {
      await _storage.deleteAll();
      return null;
    }
  }

  // Guarda los datos del usuario como un String (JSON) para mostrarlos sin
  // tener que pedirlos de nuevo al servidor.
  Future<void> saveUser(UserModel user) async {
    final value = jsonEncode(user.toJson());
    try {
      await _storage.write(key: userKey, value: value);
    } catch (_) {
      await _storage.deleteAll();
      await _storage.write(key: userKey, value: value);
    }
  }

  Future<UserModel?> readUser() async {
    try {
      final raw = await _storage.read(key: userKey);
      if (raw == null || raw.isEmpty) return null;
      final data = jsonDecode(raw);
      return data is Map<String, dynamic> ? UserModel.fromJson(data) : null;
    } catch (_) {
      return null;
    }
  }

  /// Borra la sesión guardada (logout o token vencido).
  Future<void> clear() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: userKey);
  }

  /// Leer la fecha de vencimiento 
  static DateTime? expirationOf(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      final exp = data is Map<String, dynamic> ? data['exp'] : null;
      if (exp is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          exp.toInt() * 1000,
          isUtc: true,
        );
      }
    } catch (_) {
     
    }
    return null;
  }
}
