import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/model/admin/location_model.dart';
import 'package:parcial_2/providers/sync_provider.dart';
import 'package:parcial_2/repository/ecopunto_repository.dart';
import 'package:parcial_2/services/offline/eco_points_offline_service.dart';


class EcoPuntoHandler {
  EcoPuntoHandler({required this.service, required this.repository});

  final EcoPointsOfflineService service;
  final EcoPuntoRepository repository;

  
  Future<List<LocationModel>> consultar({
    required bool incluirInactivos,
    String texto = '',
  }) async {
    final todos = await service.list(includeInactive: incluirInactivos);
    final buscado = texto.trim();
    if (buscado.isEmpty) return todos;

    if (!DatabaseHelper.isSupported) {
      return todos.where((p) => _contiene(p, buscado)).toList();
    }
    try {
      final encontrados = await repository.buscar(buscado);
      final ids = encontrados.map((p) => p.id).toSet();
      
      return todos
          .where(
            (p) =>
                ids.contains(p.id) || (p.isLocalOnly && _contiene(p, buscado)),
          )
          .toList();
    } catch (_) {
      // Si falla la base local, se filtra en memoria.
      return todos.where((p) => _contiene(p, buscado)).toList();
    }
  }

  /// Consulta de un punto guardado en el celular por su id.
  Future<LocationModel?> consultarPorId(int id) => repository.obtenerPorId(id);

  static bool _contiene(LocationModel p, String texto) {
    final t = texto.toLowerCase();
    return [
      p.name,
      p.buildingZone ?? '',
      p.description ?? '',
    ].any((campo) => campo.toLowerCase().contains(t));
  }
  // Crear, editar, eliminar
  Future<SaveResult> crear({
    required String nombre,
    String? zona,
    String? descripcion,
  }) => service.create(
    name: nombre,
    buildingZone: zona,
    description: descripcion,
  );

  Future<SaveResult> editar(int id, Map<String, dynamic> cambios) =>
      service.update(id, cambios);

  Future<SaveResult> activar(int id, {required bool activo}) =>
      service.update(id, {'is_active': activo});

  Future<SaveResult> eliminar(int id) => service.delete(id);

  /// Quita el cambio pendiente: el punto vuelve a como está en la API.
  Future<void> descartarCambio(int id) => service.discard(id);
}

final ecoPuntoHandlerProvider = Provider<EcoPuntoHandler>((ref) {
  return EcoPuntoHandler(
    service: ref.watch(ecoPointsOfflineServiceProvider),
    repository: ref.watch(ecoPuntoRepositoryProvider),
  );
});
