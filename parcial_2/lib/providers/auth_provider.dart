import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/helpers/token.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/services/auth/auth_service.dart';

/// Estado de la sesión.
enum AuthStatus {
  /// Abriendo la app: se está revisando si hay un token vigente.
  checking,
  authenticated,
  unauthenticated,
}

/// Resultado del login. La pantalla decide qué mensaje mostrar sin revelar
/// cuál dato estuvo mal.
enum LoginResult {
  success,
  invalidCredentials,
  tooManyAttempts,
  noConnection,
  timeout,
  serverError,
}

/// Proveedor de estado de la sesión. Se puede escuchar para saber si hay un
/// usuario autenticado y quién es. También se puede llamar a login() y logout().
final ChangeNotifierProvider<AuthNotifier> authProvider =
    ChangeNotifierProvider<AuthNotifier>((ref) {
      final notifier = AuthNotifier(
        ref.watch(authServiceProvider),
        ref.watch(tokenStorageProvider),
      );
      // Si el interceptor recibe un 401 en cualquier pantalla, se cierra la
      // sesión y se avisa en el login.
      final subscription = ref
          .watch(sessionEventsProvider)
          .unauthorized
          .listen((_) => notifier.expireSession());
      ref.onDispose(subscription.cancel);
      return notifier;
    });

/// Id del usuario con sesión (null si no hay). Solo avisa cuando cambia de
/// usuario, no en cada cambio de la sesión.
final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authProvider).user?.id;
});

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._service, this._storage);

  final AuthService _service;
  final TokenStorage _storage;

  /// Intentos fallidos permitidos antes de bloquear el formulario un rato.
  static const int maxAttempts = 5;
  static const Duration lockDuration = Duration(seconds: 30);

  AuthStatus _status = AuthStatus.checking;
  UserModel? _user;
  DateTime? _expiresAt;
  ApiErrorType? _sessionCheckError;
  bool _sessionExpired = false;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  Timer? _expiryTimer;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Fecha de vencimiento del token (claim "exp" del JWT), si la trae.
  DateTime? get expiresAt => _expiresAt;

  /// Error de red al revisar la sesión al abrir la app (la Splash lo muestra).
  ApiErrorType? get sessionCheckError => _sessionCheckError;

  /// Tiempo que falta para poder volver a intentar el login.
  Duration get remainingLock {
    final until = _lockedUntil;
    if (until == null) return Duration.zero;
    final left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  bool get isLocked => remainingLock > Duration.zero;

  /// Segundos que faltan del bloqueo, redondeados hacia arriba.
  int get remainingLockSeconds => (remainingLock.inMilliseconds / 1000).ceil();

  /// Al abrir la app: ¿existe token? ¿sigue vigente? (introspección).
  Future<void> restoreSession() async {
    _status = AuthStatus.checking;
    _sessionCheckError = null;
    notifyListeners();

    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      _setLoggedOut();
      return;
    }

    // Primera revisión local: el JWT trae su fecha de vencimiento.
    final expiresAt = TokenStorage.expirationOf(token);
    if (expiresAt != null && !expiresAt.isAfter(DateTime.now())) {
      await _storage.clear();
      _setLoggedOut(expired: true);
      return;
    }

    // Segunda revisión en el servidor: endpoint de introspección.
    try {
      final user = await _service.me();
      await _storage.saveUser(user);
      _setLoggedIn(user, expiresAt);
    } on ApiException catch (e) {
      if (e.isAuthError) {
        await _storage.clear();
        _setLoggedOut(expired: true);
      } else {
        // Sin conexión: si en el celular quedó guardado el usuario y el token
        // trae una fecha de vencimiento que no ha pasado (revisado arriba),
        // se entra en modo sin conexión con los datos guardados. Cuando
        // vuelva la red se verifica el token con el servidor (verifySession).
        final offline =
            e.type == ApiErrorType.noConnection ||
            e.type == ApiErrorType.timeout;
        final savedUser =
            offline && expiresAt != null && DatabaseHelper.isSupported
            ? await _storage.readUser()
            : null;
        if (savedUser != null) {
          _setLoggedIn(savedUser, expiresAt);
          return;
        }
        // Sin usuario guardado no se sabe si el token sirve: se espera en la
        // Splash con el botón "Reintentar".
        _sessionCheckError = e.type;
        notifyListeners();
      }
    }
  }

  /// Revisa de nuevo el token. Si no hay red, conserva la sesión.
  Future<void> verifySession() async {
    if (_status != AuthStatus.authenticated) return;

    final token = await _storage.readToken();
    final expiresAt = token == null ? null : TokenStorage.expirationOf(token);
    if (token == null ||
        (expiresAt != null && !expiresAt.isAfter(DateTime.now()))) {
      await expireSession();
      return;
    }

    try {
      final user = await _service.me();
      await _storage.saveUser(user);
      _user = user;
      notifyListeners();
    } on ApiException catch (e) {
      if (e.isAuthError) await expireSession();
    }
  }

  Future<LoginResult> login(String username, String password) async {
    if (isLocked) return LoginResult.tooManyAttempts;

    try {
      final auth = await _service.login(username: username, password: password);
      _failedAttempts = 0;
      _lockedUntil = null;
      _setLoggedIn(auth.user!, TokenStorage.expirationOf(auth.accessToken));
      return LoginResult.success;
    } on ApiException catch (e) {
      switch (e.type) {
        // 401 (usuario o contraseña), 403 (cuenta desactivada) y 422.
        case ApiErrorType.unauthorized:
        case ApiErrorType.forbidden:
        case ApiErrorType.validation:
          _registerFailedAttempt();
          return isLocked
              ? LoginResult.tooManyAttempts
              : LoginResult.invalidCredentials;
        case ApiErrorType.timeout:
          return LoginResult.timeout;
        case ApiErrorType.noConnection:
          return LoginResult.noConnection;
        case ApiErrorType.notFound:
        case ApiErrorType.server:
        case ApiErrorType.cancelled:
        case ApiErrorType.unknown:
          return LoginResult.serverError;
      }
    }
  }

  /// Cierre de sesión pedido por el usuario.
  Future<void> logout() async {
    await _storage.clear();
    _setLoggedOut();
    unawaited(_service.logout());
  }

  /// Cierre de sesión porque el token venció o el servidor lo rechazó.
  Future<void> expireSession() async {
    if (_status != AuthStatus.authenticated) return;
    await _storage.clear();
    _setLoggedOut(expired: true);
  }

  /// La pantalla de login pregunta una sola vez si debe avisar que la sesión
  /// expiró.
  bool consumeSessionExpired() {
    final expired = _sessionExpired;
    _sessionExpired = false;
    return expired;
  }

  void _registerFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      _failedAttempts = 0;
      _lockedUntil = DateTime.now().add(lockDuration);
    }
  }

  void _setLoggedIn(UserModel user, DateTime? expiresAt) {
    _user = user;
    _expiresAt = expiresAt;
    _status = AuthStatus.authenticated;
    _sessionCheckError = null;
    _sessionExpired = false;
    _scheduleExpiry(expiresAt);
    notifyListeners();
  }

  void _setLoggedOut({bool expired = false}) {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _user = null;
    _expiresAt = null;
    _status = AuthStatus.unauthenticated;
    _sessionCheckError = null;
    _sessionExpired = expired;
    notifyListeners();
  }

  /// Programa el cierre automático de la sesión cuando el token venza.
  void _scheduleExpiry(DateTime? expiresAt) {
    _expiryTimer?.cancel();
    if (expiresAt == null) return;
    final left = expiresAt.difference(DateTime.now());
    _expiryTimer = Timer(left.isNegative ? Duration.zero : left, expireSession);
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
