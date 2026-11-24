import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/model/admin/container_model.dart';

class RutaRepository {
  static const String _table = 'ruta';

  /// Guarda la ruta completa del usuario, en su orden.
  Future<void> guardar(int usuarioId, List<ContainerModel> ruta) async {
    Database db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      await txn.delete(_table, where: 'usuario_id = ?', whereArgs: [usuarioId]);
      for (var i = 0; i < ruta.length; i++) {
        await txn.insert(_table, {
          'usuario_id': usuarioId,
          'contenedor_id': ruta[i].id,
          'posicion': i,
          'datos': jsonEncode(ruta[i].toJson()),
        });
      }
    });
  }

  Future<List<ContainerModel>> obtener(int usuarioId) async {
    Database db = await DatabaseHelper().database;
    final filas = await db.query(
      _table,
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'posicion',
    );
    return [
      for (final fila in filas)
        ContainerModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(fila['datos'] as String)),
        ),
    ];
  }
}
