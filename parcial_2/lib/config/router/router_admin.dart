import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/admin/screen_admin.dart';
import 'package:parcial_2/presentation/shared/widgets/not_found_screen.dart';

// Perfiles que comparten permisos
const Set<UserRole> _everyone = {...UserRole.values};
const Set<UserRole> _registered = UserRole.registered;
const Set<UserRole> _admin = {UserRole.administrador};
const Set<UserRole> _operations = {UserRole.administrador, UserRole.recolector};
const Set<UserRole> _adminAndViewer = {
  UserRole.administrador,
  UserRole.interesado,
};


int? _idFrom(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');
final routerConfigAdmin = <RouterModel>[
  RouterModel(
    name: 'home',
    path: AppRoutes.home,
    title: (t) => t.menuHome,
    icon: Icons.space_dashboard_rounded,
    roles: _everyone,
    screen: (context, state) => const HomeScreen(),
  ),
  RouterModel(
    name: 'route',
    path: AppRoutes.route,
    title: (t) => t.moduleRoute,
    icon: Icons.route_rounded,
    roles: {UserRole.recolector},
    screen: (context, state) => const RouteScreen(),
    fab: (context, role) =>
        role == UserRole.recolector ? const RegisterRouteButton() : null,
  ),
  RouterModel(
    name: 'containers',
    path: AppRoutes.containers,
    title: (t) => t.moduleContainers,
    icon: Icons.delete_outline_rounded,
    roles: _registered,
    screen: (context, state) => ContainersScreen(
      locationId: int.tryParse(state.uri.queryParameters['punto'] ?? ''),
      locationName: state.uri.queryParameters['nombre'],
    ),
  ),
  RouterModel(
    name: 'alerts',
    path: AppRoutes.alerts,
    title: (t) => t.moduleAlerts,
    icon: Icons.notifications_active_outlined,
    roles: _operations,
    screen: (context, state) => const AlertsScreen(),
  ),
  RouterModel(
    name: 'ecoPoints',
    path: AppRoutes.ecoPoints,
    title: (t) => t.moduleEcoPoints,
    icon: Icons.place_outlined,
    roles: _adminAndViewer,
    screen: (context, state) => const EcoPointsScreen(),
    fab: (context, role) =>
        role == UserRole.administrador ? const NewEcoPointButton() : null,
  ),
  RouterModel(
    name: 'terminals',
    path: AppRoutes.terminals,
    title: (t) => t.moduleTerminals,
    icon: Icons.memory_rounded,
    roles: _admin,
    screen: (context, state) => const TerminalsScreen(),
    fab: (context, role) =>
        role == UserRole.administrador ? const NewTerminalButton() : null,
  ),
  RouterModel(
    name: 'collections',
    path: AppRoutes.collections,
    title: (t) => t.moduleCollections,
    icon: Icons.inventory_2_outlined,
    roles: _operations,
    screen: (context, state) => const CollectionsScreen(),
  ),
  RouterModel(
    name: 'users',
    path: AppRoutes.users,
    title: (t) => t.moduleUsers,
    icon: Icons.group_outlined,
    roles: _admin,
    screen: (context, state) => const UsersScreen(),
    fab: (context, role) =>
        role == UserRole.administrador ? const NewUserButton() : null,
  ),
  RouterModel(
    name: 'reports',
    path: AppRoutes.reports,
    title: (t) => t.moduleReports,
    icon: Icons.bar_chart_rounded,
    roles: _adminAndViewer,
    screen: (context, state) => const ReportsScreen(),
  ),
  RouterModel(
    name: 'events',
    path: AppRoutes.events,
    title: (t) => t.moduleEvents,
    icon: Icons.receipt_long_outlined,
    roles: _admin,
    screen: (context, state) => const EventsScreen(),
  ),
  RouterModel(
    name: 'profile',
    path: AppRoutes.profile,
    title: (t) => t.moduleProfile,
    icon: Icons.person_outline_rounded,
    roles: _everyone,
    screen: (context, state) => const ProfileScreen(),
  ),
];

/// Páginas de detalle y formularios: se abren encima del módulo (con flecha
/// para volver) y no aparecen en el menú. También pasan por el guard.
///
/// El orden importa: `/nuevo` va antes de `/:id` para que "nuevo" no se lea
/// como un id.
final routerConfigPages = <RouterModel>[
  RouterModel(
    name: 'terminalAssign',
    path: AppRoutes.terminalAssign,
    title: (t) => t.titleAssignTerminal,
    icon: Icons.add_rounded,
    roles: _admin,
    inDrawer: false,
    screen: (context, state) => const TerminalAssignScreen(),
  ),
  RouterModel(
    name: 'containerDetail',
    path: '${AppRoutes.containers}/:id',
    title: (t) => t.titleContainerDetail,
    icon: Icons.info_outline_rounded,
    roles: _operations,
    inDrawer: false,
    screen: (context, state) {
      final id = _idFrom(state);
      return id == null
          ? const NotFoundScreen()
          : ContainerDetailScreen(containerId: id);
    },
  ),
  RouterModel(
    name: 'fillHistory',
    path: '${AppRoutes.containers}/:id/historial',
    title: (t) => t.titleFillHistory,
    icon: Icons.show_chart_rounded,
    roles: _registered,
    inDrawer: false,
    screen: (context, state) {
      final id = _idFrom(state);
      return id == null
          ? const NotFoundScreen()
          : FillHistoryScreen(containerId: id);
    },
  ),
  RouterModel(
    name: 'userNew',
    path: AppRoutes.userNew,
    title: (t) => t.titleNewUser,
    icon: Icons.person_add_alt_1_outlined,
    roles: _admin,
    inDrawer: false,
    screen: (context, state) => const UserFormScreen(),
  ),
  RouterModel(
    name: 'userEdit',
    path: '${AppRoutes.users}/:id/editar',
    title: (t) => t.titleEditUser,
    icon: Icons.manage_accounts_outlined,
    roles: _admin,
    inDrawer: false,
    screen: (context, state) {
      final id = _idFrom(state);
      return id == null ? const NotFoundScreen() : UserFormScreen(userId: id);
    },
  ),
];

/// Busca un módulo por su nombre (lo usa el Layout para el título).
RouterModel? findAdminRouteByName(String? name) {
  if (name == null) return null;
  for (final route in routerConfigAdmin) {
    if (route.name == name) return route;
  }
  return null;
}

/// Busca la ruta por su patrón (ej. `/admin/contenedores/:id`), sea módulo o
/// página de detalle. La usa el guard para revisar los permisos.
RouterModel? findAdminRouteByPath(String? path) {
  if (path == null) return null;
  for (final route in [...routerConfigAdmin, ...routerConfigPages]) {
    if (route.path == path) return route;
  }
  return null;
}
