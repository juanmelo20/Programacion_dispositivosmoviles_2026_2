import 'package:sqflite/sqflite.dart';

import 'package:parcial_2/database/database_helper.dart';
import 'package:parcial_2/model/admin/location_model.dart';

class EcoPuntoRepository {
  static const String _table = 'ecopuntos';

  /// Reemplaza la copia guardada por la lista que acaba de llegar de la API.
  Future<void> guardarTodos(List<LocationModel> puntos) async {
    Database db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      await txn.delete(_table);
      for (var i = 0; i < puntos.length; i++) {
        await txn.insert(
          _table,
          puntos[i].toMap(position: i),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// La copia guardada, en el mismo orden en que llegó de la API.
  Future<List<LocationModel>> obtenerTodos() async {
    Database db = await DatabaseHelper().database;
    final filas = await db.query(_table, orderBy: 'posicion');
    return filas.map(LocationModel.fromMap).toList();
  }

  /// Consulta query
  Future<List<LocationModel>> buscar(String texto) async {
    Database db = await DatabaseHelper().database;
    final patron = '%${texto.trim()}%';
    final filas = await db.query(
      _table,
      where: 'nombre LIKE ? OR zona LIKE ? OR descripcion LIKE ?',
      whereArgs: [patron, patron, patron],
      orderBy: 'posicion',
    );
    return filas.map(LocationModel.fromMap).toList();
  }

  /// Consulta de un solo punto por su id
  Future<LocationModel?> obtenerPorId(int id) async {
    Database db = await DatabaseHelper().database;
    final filas = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    return filas.isEmpty ? null : LocationModel.fromMap(filas.first);
  }

  /// Fecha de la última descarga desde la API.
  Future<void> guardarFechaDescarga(DateTime fecha) async {
    Database db = await DatabaseHelper().database;
    await db.insert('sincronizacion', {
      'clave': 'ecopuntos_descargados',
      'valor': fecha.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DateTime?> obtenerFechaDescarga() async {
    Database db = await DatabaseHelper().database;
    final filas = await db.query(
      'sincronizacion',
      where: 'clave = ?',
      whereArgs: ['ecopuntos_descargados'],
    );
    if (filas.isEmpty) return null;
    return DateTime.tryParse(filas.first['valor'] as String);
  }
}
