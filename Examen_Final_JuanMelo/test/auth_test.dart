// Pruebas unitarias de la lógica de autenticación (sin servidor real).
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/token.dart';
import 'package:parcial_2/helpers/validators.dart';
import 'package:parcial_2/model/auth/auth_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/services/auth/auth_service.dart';

/// Crea un JWT de prueba con el payload indicado (la firma no importa aquí).
String fakeJwt(Map<String, dynamic> payload) {
  String part(Map<String, dynamic> data) =>
      base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.${part(payload)}.firma';
}

int secondsFromNow(Duration duration) =>
    DateTime.now().add(duration).millisecondsSinceEpoch ~/ 1000;

final userJson = <String, dynamic>{
  'id': 7,
  'username': 'jmelo',
  'email': 'jmelo@ufpso.edu.co',
  'full_name': 'Juan Melo',
  'role': 'recolector',
  'role_label': 'Recolector',
  'is_active': true,
  'created_at': '2026-10-01T10:00:00Z',
  'last_login_at': null,
};

/// Servicio falso: responde sin llamar al backend.
class FakeAuthService extends AuthService {
  FakeAuthService(this.storage) : super(Dio(), storage);

  final TokenStorage storage;
  ApiErrorType? loginError;
  ApiErrorType? meError;
  String token = fakeJwt({
    'sub': '7',
    'exp': secondsFromNow(const Duration(hours: 1)),
  });

  @override
  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    if (loginError != null) throw ApiException(loginError!);
    await storage.saveToken(token);
    return AuthModel(
      accessToken: token,
      tokenType: 'bearer',
      user: UserModel.fromJson(userJson),
    );
  }

  @override
  Future<UserModel> me() async {
    if (meError != null) throw ApiException(meError!);
    return UserModel.fromJson(userJson);
  }

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Validators (regex)', () {
    test('usuario o correo', () {
      expect(Validators.isValidUserOrEmail('jperez'), isTrue);
      expect(Validators.isValidUserOrEmail('j.perez_01-x'), isTrue);
      expect(Validators.isValidUserOrEmail('jperez@ufpso.edu.co'), isTrue);
      expect(Validators.isValidUserOrEmail('jp'), isFalse);
      expect(Validators.isValidUserOrEmail('juan perez'), isFalse);
      expect(Validators.isValidUserOrEmail('correo@'), isFalse);
      expect(Validators.isValidUserOrEmail('a' * 51), isFalse);
    });

    test('contraseña', () {
      expect(Validators.isValidPassword('123456'), isTrue);
      expect(Validators.isValidPassword('a' * 72), isTrue);
      expect(Validators.isValidPassword('12345'), isFalse);
      expect(Validators.isValidPassword('con espacio'), isFalse);
      expect(Validators.isValidPassword('a' * 73), isFalse);
    });
  });

  group('TokenStorage.expirationOf (claim exp del JWT)', () {
    test('lee la fecha de vencimiento', () {
      final token = fakeJwt({'sub': '1', 'exp': 1893456000});
      expect(TokenStorage.expirationOf(token), DateTime.utc(2030, 1, 1));
    });

    test('devuelve null si no es JWT o no trae exp', () {
      expect(TokenStorage.expirationOf('no-es-un-jwt'), isNull);
      expect(TokenStorage.expirationOf(fakeJwt({'sub': '1'})), isNull);
    });
  });

  group('Modelos', () {
    test('AuthModel mapea el token y el usuario', () {
      final auth = AuthModel.fromJson({
        'access_token': 'abc',
        'token_type': 'bearer',
        'user': userJson,
      });
      expect(auth.hasToken, isTrue);
      expect(auth.user?.role, UserRole.recolector);
      expect(auth.user?.initials, 'JM');
    });

    test('AuthModel sin token', () {
      expect(AuthModel.fromJson({'user': userJson}).hasToken, isFalse);
    });

    test('perfil desconocido', () {
      expect(UserRole.fromValue('superusuario'), UserRole.desconocido);
    });
  });

  group('ApiException', () {
    final options = RequestOptions(path: '/auth/me');

    test('códigos HTTP', () {
      expect(ApiException.typeForStatus(401), ApiErrorType.unauthorized);
      expect(ApiException.typeForStatus(403), ApiErrorType.forbidden);
      expect(ApiException.typeForStatus(422), ApiErrorType.validation);
      expect(ApiException.typeForStatus(503), ApiErrorType.server);
    });

    test('errores de red de Dio', () {
      expect(
        ApiException.fromDio(
          DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
          ),
        ).type,
        ApiErrorType.timeout,
      );
      expect(
        ApiException.fromDio(
          DioException.connectionError(requestOptions: options, reason: 'x'),
        ).type,
        ApiErrorType.noConnection,
      );
      expect(
        ApiException.fromDio(
          DioException.badResponse(
            statusCode: 401,
            requestOptions: options,
            response: Response(requestOptions: options, statusCode: 401),
          ),
        ).type,
        ApiErrorType.unauthorized,
      );
    });

    test('Dio arma bien la URL del endpoint', () {
      final request = RequestOptions(
        baseUrl: 'http://10.0.2.2:8000/api/v1',
        path: '/auth/login',
      );
      expect(request.uri.toString(), 'http://10.0.2.2:8000/api/v1/auth/login');
    });
  });

  group('AuthNotifier', () {
    late TokenStorage storage;
    late FakeAuthService service;
    late AuthNotifier auth;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = TokenStorage();
      service = FakeAuthService(storage);
      auth = AuthNotifier(service, storage);
    });

    tearDown(() => auth.dispose());

    test('login correcto guarda el token y autentica', () async {
      final result = await auth.login('jmelo', 'secreto1');
      expect(result, LoginResult.success);
      expect(auth.status, AuthStatus.authenticated);
      expect(auth.user?.role, UserRole.recolector);
      expect(await storage.readToken(), service.token);
      expect(auth.expiresAt, isNotNull);
    });

    test(
      'credenciales malas → mensaje genérico y bloqueo al 5.º intento',
      () async {
        service.loginError = ApiErrorType.unauthorized;
        for (var i = 1; i < AuthNotifier.maxAttempts; i++) {
          expect(
            await auth.login('jmelo', 'mala123'),
            LoginResult.invalidCredentials,
          );
        }
        expect(
          await auth.login('jmelo', 'mala123'),
          LoginResult.tooManyAttempts,
        );
        expect(auth.isLocked, isTrue);
        expect(auth.status, isNot(AuthStatus.authenticated));
      },
    );

    test('sin conexión no cuenta como intento fallido', () async {
      service.loginError = ApiErrorType.noConnection;
      expect(await auth.login('jmelo', 'secreto1'), LoginResult.noConnection);
      expect(auth.isLocked, isFalse);
    });

    test('sin token guardado → no autenticado', () async {
      await auth.restoreSession();
      expect(auth.status, AuthStatus.unauthenticated);
    });

    test('token vencido → se borra y se avisa', () async {
      await storage.saveToken(
        fakeJwt({'exp': secondsFromNow(const Duration(minutes: -5))}),
      );
      await auth.restoreSession();
      expect(auth.status, AuthStatus.unauthenticated);
      expect(auth.consumeSessionExpired(), isTrue);
      expect(await storage.readToken(), isNull);
    });

    test('introspección 401 → cierra la sesión', () async {
      await storage.saveToken(service.token);
      service.meError = ApiErrorType.unauthorized;
      await auth.restoreSession();
      expect(auth.status, AuthStatus.unauthenticated);
      expect(await storage.readToken(), isNull);
    });

    test(
      'introspección sin red → espera en la Splash para reintentar',
      () async {
        await storage.saveToken(service.token);
        service.meError = ApiErrorType.noConnection;
        await auth.restoreSession();
        expect(auth.status, AuthStatus.checking);
        expect(auth.sessionCheckError, ApiErrorType.noConnection);
        expect(await storage.readToken(), isNotNull);
      },
    );

    test(
      'introspección sin red con usuario guardado → entra sin conexión',
      () async {
        await storage.saveToken(service.token);
        await storage.saveUser(UserModel.fromJson(userJson));
        service.meError = ApiErrorType.noConnection;
        await auth.restoreSession();
        expect(auth.status, AuthStatus.authenticated);
        expect(auth.user?.username, UserModel.fromJson(userJson).username);
        expect(auth.sessionCheckError, isNull);
      },
    );

    test(
      'sin red con usuario guardado, pero el token no trae fecha de '
      'vencimiento → no entra sin conexión',
      () async {
        await storage.saveToken(fakeJwt({'sub': '7'}));
        await storage.saveUser(UserModel.fromJson(userJson));
        service.meError = ApiErrorType.noConnection;
        await auth.restoreSession();
        expect(auth.status, AuthStatus.checking);
        expect(auth.sessionCheckError, ApiErrorType.noConnection);
      },
    );

    test('token vigente → entra directo', () async {
      await storage.saveToken(service.token);
      await auth.restoreSession();
      expect(auth.status, AuthStatus.authenticated);
    });

    test('logout borra el token', () async {
      await auth.login('jmelo', 'secreto1');
      await auth.logout();
      expect(auth.status, AuthStatus.unauthenticated);
      expect(await storage.readToken(), isNull);
      expect(auth.consumeSessionExpired(), isFalse);
    });
  });
}
