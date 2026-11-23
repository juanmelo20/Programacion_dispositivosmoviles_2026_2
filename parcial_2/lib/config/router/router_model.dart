import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';

/// Rutas de la app. Las que reciben un id se arman con una función para no
/// escribir la URL a mano en cada pantalla.
abstract final class AppRoutes {
  /// Pantalla inicial: revisa si hay un token vigente.
  static const String splash = '/splash';

  /// Única pantalla pública.
  static const String login = '/login';

  /// Inicio de la zona privada (todos los perfiles).
  static const String home = '/admin/inicio';

  static const String containers = '/admin/contenedores';
  static String containerDetail(int id) => '/admin/contenedores/$id';
  static String fillHistory(int id) => '/admin/contenedores/$id/historial';

  /// Contenedores de un punto ecológico (filtro por query params).
  static String containersAt(int locationId, String locationName) => Uri(
    path: containers,
    queryParameters: {'punto': '$locationId', 'nombre': locationName},
  ).toString();

  static const String alerts = '/admin/alertas';
  static const String route = '/admin/ruta';
  static const String collections = '/admin/recolecciones';
  static const String ecoPoints = '/admin/puntos';

  static const String terminals = '/admin/terminales';
  static const String terminalAssign = '/admin/terminales/agregar';

  static const String users = '/admin/usuarios';
  static const String userNew = '/admin/usuarios/nuevo';
  static String userEdit(int id) => '/admin/usuarios/$id/editar';

  static const String reports = '/admin/informes';
  static const String events = '/admin/bitacora';
  static const String profile = '/admin/perfil';
}

/// Texto que depende del idioma (los títulos del menú se traducen).
typedef LocalizedText = String Function(AppLocalizations t);

/// Botón flotante de un módulo. Recibe el perfil para decidir si se muestra
/// (devuelve null si ese perfil no puede crear registros).
typedef FabBuilder = Widget? Function(BuildContext context, UserRole? role);

/// Describe una pantalla de la zona privada: ruta, título, ícono del menú y
/// qué perfiles pueden entrar.
class RouterModel {
  RouterModel({
    required this.name,
    required this.path,
    required this.screen,
    required this.title,
    required this.icon,
    required this.roles,
    this.inDrawer = true,
    this.fab,
  });

  final String name;
  final String path;
  final GoRouterWidgetBuilder screen;
  final LocalizedText title;
  final IconData icon;

  /// Perfiles con permiso para entrar a esta ruta.
  final Set<UserRole> roles;

  /// Si aparece en el menú lateral (las páginas de detalle no aparecen).
  final bool inDrawer;

  /// Botón flotante del módulo (ej. "Nuevo contenedor").
  final FabBuilder? fab;

  bool allows(UserRole? role) => role != null && roles.contains(role);
}
