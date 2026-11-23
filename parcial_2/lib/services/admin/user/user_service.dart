import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/model/auth/user_model.dart';

/// Gestión de usuarios (solo administrador).
class UserService {
  UserService(this._dio);

  final Dio _dio;

  /// GET /users
  Future<List<UserModel>> list() {
    return safeRequest(
      () => _dio.get(ApiConfig.users),
      (data) => parseList(data, UserModel.fromJson),
    );
  }

  /// POST /users
  Future<UserModel> create({
    required String username,
    required String email,
    required String password,
    required String role,
    String? fullName,
  }) {
    final name = fullName?.trim() ?? '';
    return safeRequest(
      () => _dio.post(
        ApiConfig.users,
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
          'role': role,
          'full_name': name.isEmpty ? null : name,
        },
      ),
      (data) => UserModel.fromJson(asJsonMap(data)),
    );
  }

  /// PUT /users/{id} — datos, perfil o estado (activar / desactivar).
  Future<UserModel> update(int id, Map<String, dynamic> changes) {
    return safeRequest(
      () => _dio.put(ApiConfig.user(id), data: changes),
      (data) => UserModel.fromJson(asJsonMap(data)),
    );
  }

  /// POST /users/{id}/password — el administrador asigna una contraseña nueva.
  Future<void> resetPassword(int id, String newPassword) {
    return safeRequest(
      () => _dio.post(
        ApiConfig.userPassword(id),
        data: {'new_password': newPassword},
      ),
      (_) {},
    );
  }
}
