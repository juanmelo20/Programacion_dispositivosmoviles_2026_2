import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:parcial_2/config/router/router_admin.dart';
import 'package:parcial_2/config/router/router_model.dart';
import 'package:parcial_2/l10n/app_localizations.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/presentation/admin/layout/drawer_widget.dart';
import 'package:parcial_2/presentation/shared/alerts/app_alerts.dart';
import 'package:parcial_2/presentation/shared/widgets/settings_controls.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/route_provider.dart';
import 'package:parcial_2/providers/sync_provider.dart';

/// Estructura común de la zona privada: AppBar + menú lateral + botón
/// flotante del módulo (si el perfil puede crear registros).
class Layout extends ConsumerWidget {
  const Layout({super.key, required this.child, this.routeName});

  final Widget child;

  /// Nombre de la ruta actual (para el título y el ítem activo del menú).
  final String? routeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final route = findAdminRouteByName(routeName);
    final role = ref.watch(authProvider).user?.role;

    // Al terminar de sincronizar se avisa, esté en la pantalla que esté.
    ref.listen<SyncState>(syncProvider, (previous, next) {
      final synced =
          next.lastSyncAt != null &&
          next.lastSyncAt != previous?.lastSyncAt &&
          next.lastSent > 0;
      if (synced) AppAlerts.success(context, t.syncDone(next.lastSent));
    });

    return BackButtonHandler(
      isHome: routeName == 'home',
      builder: (scaffoldKey) => Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(route?.title(t) ?? t.appTitle),
          actions: [
            if (role == UserRole.recolector && routeName != 'route')
              const RouteBadgeButton(),
            const ThemeToggleButton(),
          ],
        ),
        drawer: DrawerWidget(currentRouteName: routeName),
        floatingActionButton: route?.fab?.call(context, role),
        body: child,
      ),
    );
  }
}

/// Botón "atrás" del celular en los módulos del menú.
///
/// - En cualquier módulo distinto de Inicio: vuelve a Inicio.
/// - En Inicio: la primera vez avisa; si se pulsa otra vez en los siguientes
///   2 segundos, sale de la app.
///
/// Si el menú lateral está abierto, atrás solo lo cierra. Los diálogos y las
/// páginas de detalle son rutas propias: Flutter las cierra antes.
class BackButtonHandler extends StatefulWidget {
  const BackButtonHandler({
    super.key,
    required this.isHome,
    required this.builder,
  });

  final bool isHome;

  /// Construye el Scaffold con la llave que permite saber si el menú está
  /// abierto.
  final Widget Function(GlobalKey<ScaffoldState> scaffoldKey) builder;

  /// Tiempo para la segunda pulsación.
  static const Duration exitWindow = Duration(seconds: 2);

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastBack;

  void _onBack() {
    final scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return;
    }
    if (!widget.isHome) {
      _lastBack = null;
      context.go(AppRoutes.home);
      return;
    }

    final now = DateTime.now();
    final last = _lastBack;
    if (last != null && now.difference(last) < BackButtonHandler.exitWindow) {
      SystemNavigator.pop();
      return;
    }

    _lastBack = now;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pressBackAgainToExit),
          duration: BackButtonHandler.exitWindow,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: widget.builder(_scaffoldKey),
    );
  }
}

/// Ícono de la ruta de recolección con la cantidad de contenedores agregados.
/// Como la ruta es estado global, el número cambia desde cualquier pantalla.
class RouteBadgeButton extends ConsumerWidget {
  const RouteBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final count = ref.watch(routeProvider).length;

    return IconButton(
      tooltip: t.moduleRoute,
      onPressed: () => context.go(AppRoutes.route),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.route_rounded),
      ),
    );
  }
}
