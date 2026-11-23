import 'package:parcial_2/model/auth/user_model.dart';

/// Respuesta del login (schema `Token` del backend):
/// `{ "access_token": "...", "token_type": "bearer", "user": { ... } }`
class AuthModel {
  const AuthModel({
    required this.accessToken,
    required this.tokenType,
    this.user,
  });

  final String accessToken;
  final String tokenType;
  final UserModel? user;

  /// Verifica que la respuesta sí trajo un token.
  bool get hasToken => accessToken.trim().isNotEmpty;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return AuthModel(
      accessToken: json['access_token']?.toString() ?? '',
      tokenType: json['token_type']?.toString() ?? 'bearer',
      user: user is Map<String, dynamic> ? UserModel.fromJson(user) : null,
    );
  }
}
