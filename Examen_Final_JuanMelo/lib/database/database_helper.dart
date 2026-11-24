import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  factory DatabaseHelper() {
    return _instance;
  }

  static const String _fileName = 'ecotrack.db';

  static bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _fileName);
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  /// ecopuntos
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ecopuntos(
        id INTEGER PRIMARY KEY,
        posicion INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        zona TEXT,
        nombre_visible TEXT NOT NULL,
        activo INTEGER NOT NULL,
        contenedores INTEGER NOT NULL,
        contenedores_activos INTEGER NOT NULL
      )
    ''');
    /// pendientes
    await db.execute('''
      CREATE TABLE pendientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ecopunto_id INTEGER NOT NULL,
        accion TEXT NOT NULL,
        datos TEXT NOT NULL,
        usuario_id INTEGER NOT NULL,
        creado TEXT NOT NULL,
        error TEXT
      )
    ''');
    /// ruta
    await db.execute('''
      CREATE TABLE ruta(
        usuario_id INTEGER NOT NULL,
        contenedor_id INTEGER NOT NULL,
        posicion INTEGER NOT NULL,
        datos TEXT NOT NULL,
        PRIMARY KEY (usuario_id, contenedor_id)
      )
    ''');
    /// sincronizacion
    await db.execute('''
      CREATE TABLE sincronizacion(
        clave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');
  }
}
