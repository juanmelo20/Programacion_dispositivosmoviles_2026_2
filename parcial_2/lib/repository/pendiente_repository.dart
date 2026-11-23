import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/helpers/api_exception.dart';
import 'package:parcial_2/model/local/pending_change_model.dart';

class PendienteRepository {
  static const String _table = 'pendientes';

  Future<int> insertar(PendingChangeModel cambio) async {
    Database db = await DatabaseHelper().database;
    return await db.insert(_table, cambio.toMap()..remove('id'));
  }

  /// Los cambios del usuario, en el orden en que se hicieron.
  Future<List<PendingChangeModel>> obtenerDelUsuario(int usuarioId) async {
    Database db = await DatabaseHelper().database;
    final filas = await db.query(
      _table,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'id',
    );
    return filas.map(PendingChangeModel.fromMap).toList();
  }

  /// El cambio pendiente de un punto ecológico.
  Future<PendingChangeModel?> obtenerDelEcopunto(
    int usuarioId,
    int ecopuntoId,
  ) async {
    Database db = await DatabaseHelper().database;
    final filas = await db.query(
      _table,
      where: 'usuario_id = ? AND ecopunto_id = ?',
      whereArgs: [usuarioId, ecopuntoId],
      limit: 1,
    );
    return filas.isEmpty ? null : PendingChangeModel.fromMap(filas.first);
  }

  /// si se realiza un nuevo cambio en un punto que ya tiene un cambio pendiente, se actualiza
  Future<int> actualizar(
    int id, {
    required String accion,
    required Map<String, dynamic> datos,
  }) async {
    Database db = await DatabaseHelper().database;
    return await db.update(
      _table,
      {'accion': accion, 'datos': jsonEncode(datos), 'error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> marcarError(int id, ApiException error) async {
    Database db = await DatabaseHelper().database;
    return await db.update(
      _table,
      {'error': PendingChangeModel.errorToJson(error)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(int id) async {
    Database db = await DatabaseHelper().database;
    return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
