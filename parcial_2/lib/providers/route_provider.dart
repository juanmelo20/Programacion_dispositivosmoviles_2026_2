import 'package:flutter_riverpod/legacy.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/model/admin/container_model.dart';
import 'package:parcial_2/providers/api_provider.dart';
import 'package:parcial_2/providers/auth_provider.dart';
import 'package:parcial_2/providers/sync_provider.dart';
import 'package:parcial_2/repository/ruta_repository.dart';
import 'package:parcial_2/services/admin/container/container_service.dart';

/// "Carrito" con estado global: la ruta de recolección del recolector.
///
/// Cualquier pantalla puede agregar o quitar contenedores (lista, alertas,
/// detalle) y el contador del menú se actualiza solo. Cada recolector tiene
/// su propia ruta y se guarda en SQLite (tabla `ruta`): si cierra la app y
/// vuelve a entrar, la ruta sigue ahí. Con conexión, el llenado de cada
/// contenedor se pone al día con la API.
final routeProvider =
    StateNotifierProvider<RouteNotifier, List<ContainerModel>>((ref) {
      final userId = ref.watch(currentUserIdProvider);
      return RouteNotifier(
        userId: userId,
        repository: ref.watch(rutaRepositoryProvider),
        api: ref.watch(containerServiceProvider),
      );
    });

class RouteNotifier extends StateNotifier<List<ContainerModel>> {
  RouteNotifier({this.userId, this.repository, this.api}) : super(const []) {
    _load();
  }

  final int? userId;
  final RutaRepository? repository;

  /// Para poner al día los datos de los contenedores de la ruta.
  final ContainerService? api;

  bool get _persist =>
      userId != null && repository != null && DatabaseHelper.isSupported;

  /// Al crear el provider (al iniciar sesión): lee la ruta guardada.
  Future<void> _load() async {
    if (!_persist) return;
    try {
      final saved = await repository!.obtener(userId!);
      if (!mounted || saved.isEmpty) return;
      final ids = saved.map((c) => c.id).toSet();
      state = [...saved, ...state.where((c) => !ids.contains(c.id))];
    } catch (_) {
      // Si la base local falla, la ruta funciona igual en memoria.
      return;
    }
    // Lo guardado puede ser de hace días: se pone al día con la API.
    await refreshFromApi();
  }

  /// Con conexión, cambia los datos guardados de cada contenedor por los
  /// actuales de la API (el llenado cambia con cada depósito y con cada
  /// recolección). Los que ya no existen salen de la ruta. Sin conexión se
  /// queda con lo guardado en el celular.
  Future<void> refreshFromApi() async {
    if (api == null || state.isEmpty) return;
    try {
      final fresh = await api!.list(includeInactive: true);
      if (!mounted) return;
      final byId = {for (final c in fresh) c.id: c};
      state = [
        for (final c in state)
          if (byId[c.id] != null) byId[c.id]!,
      ];
    } catch (_) {
      // Sin conexión: se ve lo guardado.
    }
  }

  /// Cada cambio de la ruta (agregar, quitar, reordenar, vaciar) pasa por
  /// aquí, así que también se guarda en SQLite.
  @override
  set state(List<ContainerModel> value) {
    super.state = value;
    if (_persist) repository!.guardar(userId!, value).catchError((_) {});
  }

  bool contains(int containerId) => state.any((c) => c.id == containerId);

  /// Total de residuos que se van a recoger.
  int get totalUnits => state.fold(0, (sum, c) => sum + c.currentCount);

  void add(ContainerModel container) {
    if (contains(container.id)) return;
    state = [...state, container];
  }

  /// Agrega varios a la vez (por ejemplo todas las alertas). Devuelve cuántos
  /// eran nuevos.
  int addAll(Iterable<ContainerModel> containers) {
    final added = containers.where((c) => !contains(c.id)).toList();
    if (added.isNotEmpty) state = [...state, ...added];
    return added.length;
  }

  /// Vuelve a poner un contenedor en su posición (botón "Deshacer").
  void insert(int index, ContainerModel container) {
    if (contains(container.id)) return;
    final items = [...state];
    items.insert(index.clamp(0, items.length), container);
    state = items;
  }

  void remove(int containerId) {
    state = state.where((c) => c.id != containerId).toList();
  }

  void removeAll(Iterable<int> containerIds) {
    final ids = containerIds.toSet();
    state = state.where((c) => !ids.contains(c.id)).toList();
  }

  /// Agrega o quita. Devuelve true si quedó en la ruta.
  bool toggle(ContainerModel container) {
    if (contains(container.id)) {
      remove(container.id);
      return false;
    }
    add(container);
    return true;
  }

  /// Cambia el orden de la ruta (lista reordenable). [newIndex] es la
  /// posición final del elemento, ya descontando el que se movió.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    final items = [...state];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex.clamp(0, items.length), item);
    state = items;
  }

  void clear() => state = const [];
}
