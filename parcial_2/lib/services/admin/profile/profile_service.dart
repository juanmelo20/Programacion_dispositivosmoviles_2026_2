import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_request.dart';
import 'package:parcial_2/model/auth/user_model.dart';

/// Perfil del usuario: ruta protegida que necesita el token.
///
/// El interceptor de Dio agrega la cabecera `Authorization: Bearer <token>`;
/// sin un token válido el backend responde 401.
class ProfileService {
  ProfileService(this._dio);

  final Dio _dio;

  /// GET /auth/me
  Future<UserModel> getProfile() {
    return safeRequest(
      () => _dio.get(ApiConfig.me),
      (data) => UserModel.fromJson(asJsonMap(data)),
    );
  }
}
