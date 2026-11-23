// kIsWeb y defaultTargetPlatform: para saber en qué plataforma corre la app.
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._(); 

  static const String _urlFromEnv = String.fromEnvironment('API_URL');

  static const String localBackend = 'http://127.0.0.1:8000';
  /// URL del servidor según dónde corra la app:
  /// - Web (Chrome): el mismo origen de la página. El proxy configurado en
  ///   web_dev_config.yaml reenvía /api y /media al backend y así se evita
  ///   el bloqueo CORS del navegador.
  ///   API_URL=http://127.0.0.1:8000, o por wifi con la IP del PC.
  static String get baseUrl {
    if (_urlFromEnv.isNotEmpty) return _urlFromEnv;
    if (kIsWeb) return Uri.base.origin;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return localBackend;
  }

  /// Prefijo de la versión de la API.
  static const String apiPrefix = '/api/v1';


  static String mediaUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl$path';
  }

  /// Tiempos máximos de espera. 
  static const Duration connectTimeout = Duration(seconds: 10); /// Tiempo máximo de espera para establecer la conexión con el servidor.
  static const Duration receiveTimeout = Duration(seconds: 20); /// Tiempo máximo de espera para recibir la respuesta del servidor.

  /// Inicio de sesión (OAuth2 password flow → x-www-form-urlencoded).
  static const String login = '/auth/login';

  /// Cierre de sesión en el servidor.
  static const String logout = '/auth/logout';

  /// Usuario autenticado.
  static const String me = '/auth/me';

  /// Rutas que no llevan token ni deben cerrar la sesión si responden 401.
  /// El logout no necesita token: el servidor solo borra su cookie.
  static const Set<String> publicPaths = {login, logout};

  ///Modulos de la app
  static const String containers = '/containers';
  static const String alerts = '/containers/alerts';
  static String container(int id) => '/containers/$id';
  static String fillHistory(int id) => '/containers/$id/fill-history';
  static String containerCollections(int id) => '/containers/$id/collections';

  static const String collections = '/collections';

  static const String locations = '/locations';
  static String location(int id) => '/locations/$id';

  static const String overview = '/reports/overview';
  static const String analytics = '/reports/analytics';

  static const String users = '/users';
  static String user(int id) => '/users/$id';
  static String userPassword(int id) => '/users/$id/password';

  static const String terminals = '/terminales';
  static String terminalByCode(String code) => '/terminales/codigo/$code';
  static const String terminalAssign = '/terminales/asignar';
  static String terminal(int id) => '/terminales/$id';

  static const String events = '/events';
  static const String eventTypes = '/events/types';
}
