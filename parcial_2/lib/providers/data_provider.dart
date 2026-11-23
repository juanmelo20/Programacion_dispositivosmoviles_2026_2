import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import 'package:parcial_2/handler/ecopunto_handler.dart';
import 'package:parcial_2/model/admin/collection_model.dart';
import 'package:parcial_2/model/admin/container_detail_model.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/model/admin/report_model.dart';
import 'package:parcial_2/model/admin/terminal_model.dart';
import 'package:parcial_2/model/auth/user_model.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/sync_provider.dart';

/// Datos que se consultan a la API.
///
/// Son FutureProvider: mientras la petición está en curso el estado es
/// "loading" (la pantalla muestra el esqueleto), luego "data" o "error".
/// `autoDispose` libera los datos cuando ninguna pantalla los usa, y
/// `family` crea un estado distinto por cada filtro (por eso al cambiar de
/// pestaña aparece el esqueleto mientras llegan los datos de esa pestaña).

/// Filtros de la lista de contenedores.
typedef ContainersQuery = ({
  String? category,
  String? status,
  String query,
  int? locationId,
  bool includeInactive,
});

final containersProvider = FutureProvider.autoDispose
    .family<List<ContainerModel>, ContainersQuery>((ref, filter) {
      return ref
          .watch(containerServiceProvider)
          .list(
            category: filter.category,
            status: filter.status,
            query: filter.query,
            locationId: filter.locationId,
            includeInactive: filter.includeInactive,
          );
    });

final alertsProvider = FutureProvider.autoDispose<List<ContainerModel>>((ref) {
  return ref.watch(containerServiceProvider).alerts();
});

final containerDetailProvider = FutureProvider.autoDispose
    .family<ContainerDetailModel, int>((ref, id) {
      return ref.watch(containerServiceProvider).detail(id);
    });

final fillHistoryProvider = FutureProvider.autoDispose
    .family<FillHistoryModel, int>((ref, id) {
      return ref.watch(containerServiceProvider).fillHistory(id);
    });

/// Filtros del historial de recolecciones.
typedef CollectionsQuery = ({int days, String? category});

final collectionsProvider = FutureProvider.autoDispose
    .family<List<CollectionModel>, CollectionsQuery>((ref, filter) {
      return ref
          .watch(collectionServiceProvider)
          .list(days: filter.days, category: filter.category);
    });

/// `true` incluye los puntos inactivos (solo lo usa el administrador).
///
/// Pasa por el servicio offline: con conexión trae los datos de la API y los
/// guarda en SQLite; sin conexión muestra la copia guardada en el celular.
final locationsProvider = FutureProvider.autoDispose
    .family<List<LocationModel>, bool>((ref, includeInactive) {
      return ref
          .watch(ecoPointsOfflineServiceProvider)
          .list(includeInactive: includeInactive);
    });

/// Filtros de la pantalla de puntos ecológicos.
typedef EcoPointsQuery = ({bool includeInactive, String text});

/// Puntos ecológicos con búsqueda: pasa por el handler, que consulta SQLite
/// con `LIKE` (ver [EcoPuntoHandler.consultar]).
final ecoPointsSearchProvider = FutureProvider.autoDispose
    .family<List<LocationModel>, EcoPointsQuery>((ref, query) {
      return ref
          .watch(ecoPuntoHandlerProvider)
          .consultar(
            incluirInactivos: query.includeInactive,
            texto: query.text,
          );
    });

final overviewProvider = FutureProvider.autoDispose<OverviewModel>((ref) {
  return ref.watch(reportServiceProvider).overview();
});

/// Filtros del informe.
typedef AnalyticsQuery = ({int days, String? category, int? locationId});

final analyticsProvider = FutureProvider.autoDispose
    .family<AnalyticsModel, AnalyticsQuery>((ref, filter) {
      return ref
          .watch(reportServiceProvider)
          .analytics(
            days: filter.days,
            category: filter.category,
            locationId: filter.locationId,
          );
    });

final usersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  return ref.watch(userServiceProvider).list();
});

final terminalsProvider = FutureProvider.autoDispose<List<TerminalModel>>((ref) {
  return ref.watch(terminalServiceProvider).list();
});

final eventTypesProvider = FutureProvider.autoDispose<Map<String, String>>((
  ref,
) {
  return ref.watch(eventServiceProvider).types();
});

final profileProvider = FutureProvider.autoDispose<UserModel>((ref) {
  return ref.watch(profileServiceProvider).getProfile();
});

/// Después de guardar o registrar algo, se marcan como viejos los datos de
/// operación para que las pantallas los vuelvan a pedir.
///
/// Recibe `ref.invalidate` (desde un widget) o `container.invalidate` (desde
/// una acción que termina después de cerrar la pantalla).
void refreshOperationalData(void Function(ProviderOrFamily) invalidate) {
  invalidate(containersProvider);
  invalidate(alertsProvider);
  invalidate(containerDetailProvider);
  invalidate(fillHistoryProvider);
  invalidate(collectionsProvider);
  invalidate(overviewProvider);
  invalidate(locationsProvider);
  invalidate(ecoPointsSearchProvider);
  invalidate(terminalsProvider);
}
