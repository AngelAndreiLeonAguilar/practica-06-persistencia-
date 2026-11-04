import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/filtro.dart';
import '../models/nota.dart';
import '../models/tarea.dart';

/// Acceso único a la base de datos SQLite local.
///
/// Contiene dos tablas:
/// * `tareas`: entidad principal del gestor offline.
/// * `notas`: ejemplo guiado de la práctica.
class DB {
  DB._();

  static Database? _db;

  static const String _nombreBaseDatos = 'gestor_tareas.db';
  static const int _version = 1;

  /// Base de datos lista para usarse. La primera llamada la abre.
  static Future<Database> get database async {
    if (_db != null) return _db!;
    return init();
  }

  /// Abre la base de datos. [ruta] permite usar una base en memoria en pruebas.
  static Future<Database> init({String? ruta}) async {
    if (_db != null) return _db!;
    final camino = ruta ?? join(await getDatabasesPath(), _nombreBaseDatos);
    _db = await openDatabase(
      camino,
      version: _version,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _crearTablas,
    );
    return _db!;
  }

  static Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        contenido TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tareas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL DEFAULT '',
        prioridad TEXT NOT NULL DEFAULT 'media',
        completada INTEGER NOT NULL DEFAULT 0,
        pendiente_sincronizar INTEGER NOT NULL DEFAULT 1,
        creada_en TEXT NOT NULL,
        actualizada_en TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_tareas_completada ON tareas(completada)',
    );
  }

  /// Cierra la conexión; se usa en pruebas y al reiniciar la app.
  static Future<void> cerrar() async {
    await _db?.close();
    _db = null;
  }

  // ---------------------------------------------------------------------------
  // Tareas (proyecto integrador)
  // ---------------------------------------------------------------------------

  static Future<int> insertarTarea(Tarea tarea) async {
    final db = await database;
    return db.insert('tareas', tarea.aMapa(incluirId: false));
  }

  static Future<List<Tarea>> listarTareas({
    FiltroTareas filtro = FiltroTareas.todas,
    String? busqueda,
  }) async {
    final db = await database;
    final condiciones = <String>[];
    final argumentos = <Object?>[];

    switch (filtro) {
      case FiltroTareas.pendientes:
        condiciones.add('completada = ?');
        argumentos.add(0);
      case FiltroTareas.completadas:
        condiciones.add('completada = ?');
        argumentos.add(1);
      case FiltroTareas.todas:
        break;
    }

    final texto = busqueda?.trim() ?? '';
    if (texto.isNotEmpty) {
      condiciones.add('(titulo LIKE ? OR descripcion LIKE ?)');
      final patron = '%$texto%';
      argumentos
        ..add(patron)
        ..add(patron);
    }

    final filas = await db.query(
      'tareas',
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: 'completada ASC, id DESC',
    );
    return filas.map(Tarea.desdeMapa).toList();
  }

  static Future<Tarea?> obtenerTarea(int id) async {
    final db = await database;
    final filas = await db.query('tareas', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return Tarea.desdeMapa(filas.first);
  }

  static Future<int> actualizarTarea(Tarea tarea) async {
    final db = await database;
    return db.update(
      'tareas',
      tarea.aMapa(incluirId: false),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  static Future<int> eliminarTarea(int id) async {
    final db = await database;
    return db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }

  /// Cambios locales que todavía no se envían a un servidor.
  static Future<int> contarPendientesSincronizar() async {
    final db = await database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM tareas WHERE pendiente_sincronizar = 1',
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// Simula el envío al servidor marcando todos los cambios como sincronizados.
  static Future<int> marcarTodoSincronizado() async {
    final db = await database;
    return db.update('tareas', {
      'pendiente_sincronizar': 0,
    }, where: 'pendiente_sincronizar = 1');
  }

  static Future<int> contarTareas({bool? completadas}) async {
    final db = await database;
    final resultado = await db.rawQuery(
      completadas == null
          ? 'SELECT COUNT(*) AS total FROM tareas'
          : 'SELECT COUNT(*) AS total FROM tareas WHERE completada = ?',
      completadas == null ? null : [completadas ? 1 : 0],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Notas (ejemplo guiado)
  // ---------------------------------------------------------------------------

  static Future<int> insertarNota(String titulo, String contenido) async {
    final db = await database;
    return db.insert('notas', {'titulo': titulo, 'contenido': contenido});
  }

  static Future<List<Nota>> listarNotas() async {
    final db = await database;
    final filas = await db.query('notas', orderBy: 'id DESC');
    return filas.map(Nota.desdeMapa).toList();
  }

  static Future<int> actualizarNota(
    int id,
    String titulo,
    String contenido,
  ) async {
    final db = await database;
    return db.update(
      'notas',
      {'titulo': titulo, 'contenido': contenido},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> eliminarNota(int id) async {
    final db = await database;
    return db.delete('notas', where: 'id = ?', whereArgs: [id]);
  }
}
