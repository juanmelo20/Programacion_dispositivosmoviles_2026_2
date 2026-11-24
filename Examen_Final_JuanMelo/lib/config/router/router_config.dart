import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_admin.dart';
import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/presentation/admin/layout/layout.dart';
import 'package:parcial_2/presentation/public/auth/auth_screen.dart';
import 'package:parcial_2/presentation/public/splash/splash_screen.dart';
import 'package:parcial_2/presentation/shared/widgets/not_found_screen.dart';
import 'package:parcial_2/providers/auth_provider.dart';

/// Router de la app con su guard.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authProvider.notifier);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth,
    redirect: (context, state) => authGuard(auth, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const AuthScreen(),
      ),
      // Módulos: comparten el Layout (AppBar + menú lateral).
      ShellRoute(
        builder: (context, state, child) =>
            Layout(routeName: state.topRoute?.name, child: child),
        routes: [
          for (final screen in routerConfigAdmin)
            GoRoute(
              path: screen.path,
              name: screen.name,
              builder: screen.screen,
            ),
        ],
      ),
      // Detalles y formularios: pantalla completa con flecha para volver.
      for (final page in routerConfigPages)
        GoRoute(path: page.path, name: page.name, builder: page.screen),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );

  ref.onDispose(router.dispose);
  return router;
});

/// Guard de rutas (GUARD):
/// - Revisando la sesión → se queda en la Splash.
/// - Sin token → solo puede estar en el login.
/// - Con token → no puede volver al login; y solo entra a las pantallas que
///   su perfil tiene permitidas (módulos y páginas de detalle). Si escribe
///   la URL de una pantalla que no le corresponde, vuelve al inicio.
String? authGuard(AuthNotifier auth, GoRouterState state) {
  final location = state.matchedLocation;

  switch (auth.status) {
    case AuthStatus.checking:
      return location == AppRoutes.splash ? null : AppRoutes.splash;

    case AuthStatus.unauthenticated:
      return location == AppRoutes.login ? null : AppRoutes.login;

    case AuthStatus.authenticated:
      if (location == AppRoutes.login || location == AppRoutes.splash) {
        return AppRoutes.home;
      }
      final route = findAdminRouteByPath(state.fullPath);
      if (route != null &&
          !route.allows(auth.user?.role) &&
          location != AppRoutes.home) {
        return AppRoutes.home;
      }
      return null;
  }
}
