import 'package:dio/dio.dart';

import 'package:parcial_2/config/api/api_config.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/token.dart';
import 'package:parcial_2/model/auth/auth_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';

/// Peticiones de autenticación contra el backend de EcoTrack.
class AuthService {
  AuthService(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  /// POST /auth/login
  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    try {
      //  Petición a la API con login. FastAPI usa el flujo OAuth2, por eso
      //    se envía como formulario (x-www-form-urlencoded) y no como JSON.
      final response = await _dio.post<Map<String, dynamic>>( 
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      //  Estatus de la petición.
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw ApiException(
          ApiErrorType.unknown,
          statusCode: response.statusCode,
          debugDetail: 'Respuesta inesperada del login',
        );
      }

      //  Mapear la respuesta y verificar que exista el token.
      final auth = AuthModel.fromJson(data);
      final user = auth.user;
      if (!auth.hasToken || user == null) {
        throw const ApiException(
          ApiErrorType.unknown,
          debugDetail: 'El login no devolvió token',
        );
      }

      await _storage.saveToken(auth.accessToken);
      await _storage.saveUser(user);

      return auth;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(ApiErrorType.unknown, debugDetail: e.toString());
    }
  }

  /// GET /auth/me — Introspección del token.
  Future<UserModel> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConfig.me);
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw ApiException(
          ApiErrorType.unknown,
          statusCode: response.statusCode,
        );
      }
      return UserModel.fromJson(data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException(ApiErrorType.unknown, debugDetail: e.toString());
    }
  }

  /// POST /auth/logout — Avisa al servidor. Si falla, no afecta el cierre de
  /// sesión local.
  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiConfig.logout);
    } catch (_) {
      // Se ignora: la sesión local ya se cerró.
    }
  }
}
