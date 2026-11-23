import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/model/local/pending_change_model.dart';
import 'package:parcial_2/repository/ecopunto_repository.dart';
import 'package:parcial_2/repository/pendiente_repository.dart';
import 'package:parcial_2/services/admin/location/location_service.dart';


enum SaveResult {
  /// Llegó a la API.
  synced,
  savedLocally,
}

class SyncSummary {
  const SyncSummary({this.sent = 0, this.failed = 0, this.offline = false});

  /// Cambios que llegaron a la API.
  final int sent;

  /// Cambios que la API rechazó (quedan marcados con el error).
  final int failed;

  /// Se detuvo porque no hay conexión.
  final bool offline;
}

abstract interface class SyncStatusSink {
  /// Indica si el dispositivo está sin conexión con la API. Si es true, no se
  /// intenta enviar cambios a la API y se guardan localmente; si es false, se
  /// intenta enviar a la API y si falla se marca como sin conexión.
  bool get isDeviceOffline;

  void reportOnline();
  void reportOffline();
  void localChangesUpdated();
}

class EcoPointsOfflineService {
  EcoPointsOfflineService({
    required this.api,
    required this.ecopuntos,
    required this.pendientes,
    required this.userId,
    required this.status,
  });

  final LocationService api;
  final EcoPuntoRepository ecopuntos;
  final PendienteRepository pendientes;
  final int? userId;
  final SyncStatusSink status;

  /// El almacenamiento local solo existe en el celular y con sesión.
  bool get _local => DatabaseHelper.isSupported && userId != null;

  Future<void> _ultimoTurno = Future.value();

  Future<T> _porTurnos<T>(Future<T> Function() operacion) {
    final resultado = _ultimoTurno.then((_) => operacion());
    _ultimoTurno = resultado.then<void>((_) {}, onError: (_) {});
    return resultado;
  }

  /// Errores que significan "no hay conexión con el servidor".
  static bool isNetworkError(Object error) =>
      error is ApiException &&
      (error.type == ApiErrorType.noConnection ||
          error.type == ApiErrorType.timeout);

  // Leer

  Future<List<LocationModel>> list({required bool includeInactive}) async {
    if (!_local) return api.list(includeInactive: includeInactive);

    if (!status.isDeviceOffline) {
      final List<LocationModel> fresh;
      try {
        fresh = await api.list(includeInactive: includeInactive);
      } catch (error) {
        if (!isNetworkError(error)) rethrow;
        status.reportOffline();
        return _savedCopy(includeInactive);
      }
      status.reportOnline();
      try {
        await _saveCopy(fresh, includeInactive: includeInactive);
        final changes = await pendientes.obtenerDelUsuario(userId!);
        // Hay conexión y quedaban cambios por enviar
        if (changes.any((c) => c.error == null)) status.localChangesUpdated();
        return _filter(_applyChanges(fresh, changes), includeInactive);
      } catch (_) {
        return fresh;
      }
    }
    return _savedCopy(includeInactive);
  }

  /// Sin conexión: la copia guardada en el celular + los cambios pendientes.
  Future<List<LocationModel>> _savedCopy(bool includeInactive) async {
    final saved = await ecopuntos.obtenerTodos();
    final changes = await pendientes.obtenerDelUsuario(userId!);
    if (saved.isEmpty && changes.isEmpty) {
      throw const ApiException(ApiErrorType.noConnection);
    }
    return _filter(_applyChanges(saved, changes), includeInactive);
  }

  /// Guarda la copia. 
  Future<void> _saveCopy(
    List<LocationModel> fresh, {
    required bool includeInactive,
  }) async {
    var toSave = fresh;
    if (!includeInactive) {
      final ids = fresh.map((p) => p.id).toSet();
      final saved = await ecopuntos.obtenerTodos();
      toSave = [
        ...fresh,
        ...saved.where((p) => !p.isActive && !ids.contains(p.id)),
      ];
    }
    await ecopuntos.guardarTodos(toSave);
    await ecopuntos.guardarFechaDescarga(DateTime.now());
  }

  static List<LocationModel> _filter(
    List<LocationModel> points,
    bool includeInactive,
  ) => includeInactive ? points : points.where((p) => p.isActive).toList();

  static List<LocationModel> _applyChanges(
    List<LocationModel> base,
    List<PendingChangeModel> changes,
  ) {
    final byId = {for (final p in base) p.id: p};
    final created = <LocationModel>[];

    for (final change in changes) {
      final data = change.data;
      switch (change.action) {
        case PendingAction.create:
          final name = data['name'] as String? ?? '';
          final zone = data['building_zone'] as String?;
          created.add(
            LocationModel(
              id: change.ecoPointId,
              name: name,
              description: data['description'] as String?,
              buildingZone: zone,
              displayName: LocationModel.displayNameFor(name, zone),
              isActive: true,
              containerCount: 0,
              activeContainerCount: 0,
              pendingAction: PendingAction.create,
              syncError: change.error,
            ),
          );
        case PendingAction.update:
          final current = byId[change.ecoPointId];
          if (current == null) break;
          byId[change.ecoPointId] = current.copyWith(
            name: data['name'] as String?,
            description: data['description'] as String?,
            buildingZone: data['building_zone'] as String?,
            isActive: data['is_active'] as bool?,
            pendingAction: PendingAction.update,
            syncError: change.error,
          );
        case PendingAction.delete:
          final current = byId[change.ecoPointId];
          if (current == null) break;
          byId[change.ecoPointId] = current.copyWith(
            pendingAction: PendingAction.delete,
            syncError: change.error,
          );
      }
    }

    // Los creados sin conexión van primero.
    return [
      ...created.reversed,
      for (final p in base)
        if (byId.containsKey(p.id)) byId[p.id]!,
    ];
  }

  // Crear, editar, eliminar

  Future<SaveResult> create({
    required String name,
    String? description,
    String? buildingZone,
  }) => _porTurnos(() async {
    final online = await _tryOnline(
      () => api.create(
        name: name,
        description: description,
        buildingZone: buildingZone,
      ),
    );
    if (online) return SaveResult.synced;

    // Sin conexión: id temporal negativo hasta que la API le dé el real.
    await pendientes.insertar(
      PendingChangeModel(
        ecoPointId: -DateTime.now().millisecondsSinceEpoch,
        action: PendingAction.create,
        data: {
          'name': name,
          'description': description,
          'building_zone': buildingZone,
        },
        userId: userId!,
        createdAt: DateTime.now(),
      ),
    );
    status.localChangesUpdated();
    return SaveResult.savedLocally;
  });

  Future<SaveResult> update(int id, Map<String, dynamic> changes) =>
      _porTurnos(() async {
        final pending = _local
            ? await pendientes.obtenerDelEcopunto(userId!, id)
            : null;

        if (pending == null) {
          if (await _tryOnline(() => api.update(id, changes))) {
            return SaveResult.synced;
          }
          await pendientes.insertar(
            PendingChangeModel(
              ecoPointId: id,
              action: PendingAction.update,
              data: changes,
              userId: userId!,
              createdAt: DateTime.now(),
            ),
          );
        } else if (pending.action == PendingAction.delete) {
          // Estaba por eliminarse (o la API no dejó eliminarlo) y ahora lo
          // edita: lo que queda pendiente es la edición.
          await pendientes.actualizar(
            pending.id!,
            accion: PendingAction.update,
            datos: changes,
          );
        } else {
          // Ya tenía un cambio pendiente 
          // juntan los datos en ese mismo cambio.
          await pendientes.actualizar(
            pending.id!,
            accion: pending.action,
            datos: {...pending.data, ...changes},
          );
        }
        status.localChangesUpdated();
        return SaveResult.savedLocally;
      });

  Future<SaveResult> delete(int id) => _porTurnos(() async {
    final pending = _local
        ? await pendientes.obtenerDelEcopunto(userId!, id)
        : null;

    if (pending?.action == PendingAction.create) {
      // Se creó y se eliminó sin conexión: nunca llega a la API.
      await pendientes.eliminar(pending!.id!);
      status.localChangesUpdated();
      return SaveResult.synced;
    }
    if (pending == null) {
      if (await _tryOnline(() => api.delete(id))) return SaveResult.synced;
      await pendientes.insertar(
        PendingChangeModel(
          ecoPointId: id,
          action: PendingAction.delete,
          data: const {},
          userId: userId!,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      // Tenía una edición pendiente: ahora lo pendiente es eliminarlo.
      await pendientes.actualizar(
        pending.id!,
        accion: PendingAction.delete,
        datos: const {},
      );
    }
    status.localChangesUpdated();
    return SaveResult.savedLocally;
  });

  /// Quita el cambio pendiente de un punto: vuelve a lo que dice la API.
  Future<void> discard(int id) => _porTurnos(() async {
    if (!_local) return;
    final pending = await pendientes.obtenerDelEcopunto(userId!, id);
    if (pending != null) await pendientes.eliminar(pending.id!);
    status.localChangesUpdated();
  });

  /// Ejecuta la petición en la API. Devuelve false si no hay conexión (y hay
  /// almacenamiento local para guardarlo); cualquier otro error se lanza para
  /// que la pantalla lo muestre (por ejemplo, un nombre repetido).
  Future<bool> _tryOnline(Future<Object?> Function() request) async {
    if (_local && status.isDeviceOffline) return false;
    try {
      await request();
      if (_local) status.reportOnline();
      return true;
    } catch (error) {
      if (!_local || !isNetworkError(error)) rethrow;
      status.reportOffline();
      return false;
    }
  }

  // Sincronizar

  /// Envía a la API los cambios pendientes, en el orden en que se hicieron.
  Future<SyncSummary> sync() => _porTurnos(_sync);

  Future<SyncSummary> _sync() async {
    if (!_local) return const SyncSummary();
    final changes = await pendientes.obtenerDelUsuario(userId!);
    var sent = 0;
    var failed = 0;

    for (final change in changes) {
      // Los que la API ya rechazó esperan a que el usuario los corrija.
      if (change.error != null) continue;
      try {
        await _send(change);
        await pendientes.eliminar(change.id!);
        sent++;
      } on ApiException catch (error) {
        if (isNetworkError(error)) {
          status.reportOffline();
          return SyncSummary(sent: sent, failed: failed, offline: true);
        }
        // Sesión vencida o servidor caído: se intenta después.
        if (error.type == ApiErrorType.unauthorized ||
            error.type == ApiErrorType.server ||
            error.type == ApiErrorType.cancelled) {
          break;
        }
        // La API rechazó el cambio (ej. nombre repetido): queda con su error.
        await pendientes.marcarError(change.id!, error);
        failed++;
      }
    }
    if (sent > 0) status.reportOnline();
    return SyncSummary(sent: sent, failed: failed);
  }

  Future<void> _send(PendingChangeModel change) async {
    final data = change.data;
    switch (change.action) {
      case PendingAction.create:
        await api.create(
          name: data['name'] as String,
          description: data['description'] as String?,
          buildingZone: data['building_zone'] as String?,
        );
      case PendingAction.update:
        await api.update(change.ecoPointId, data);
      case PendingAction.delete:
        try {
          await api.delete(change.ecoPointId);
        } on ApiException catch (error) {
          // Si ya no existe en el servidor, el objetivo se cumplió.
          if (error.type != ApiErrorType.notFound) rethrow;
        }
    }
  }
}
