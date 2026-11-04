import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas/database/db.dart';
import 'package:gestor_tareas/models/filtro.dart';
import 'package:gestor_tareas/models/tarea.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DB.cerrar();
    await DB.init(ruta: inMemoryDatabasePath);
  });

  tearDown(() async {
    await DB.cerrar();
  });

  Tarea nuevaTarea({
    String titulo = 'Tarea de prueba',
    String descripcion = '',
    Prioridad prioridad = Prioridad.media,
    bool completada = false,
  }) {
    return Tarea(
      titulo: titulo,
      descripcion: descripcion,
      prioridad: prioridad,
      completada: completada,
      creadaEn: DateTime(2026, 11, 4, 12),
      actualizadaEn: DateTime(2026, 11, 4, 12),
    );
  }

  group('CRUD de tareas en SQLite', () {
    test('inserta y consulta tareas', () async {
      await DB.insertarTarea(nuevaTarea(titulo: 'Estudiar SQLite'));
      await DB.insertarTarea(nuevaTarea(titulo: 'Entregar práctica'));

      final tareas = await DB.listarTareas();

      expect(tareas, hasLength(2));
      expect(tareas.first.titulo, 'Entregar práctica');
      expect(tareas.first.id, isNotNull);
      expect(tareas.first.pendienteSincronizar, isTrue);
      expect(tareas.first.prioridad, Prioridad.media);
    });

    test('actualiza título, descripción y prioridad', () async {
      final id = await DB.insertarTarea(nuevaTarea());
      final guardada = await DB.obtenerTarea(id);

      await DB.actualizarTarea(
        guardada!.copiarCon(
          titulo: 'Título corregido',
          descripcion: 'Nueva descripción',
          prioridad: Prioridad.alta,
          pendienteSincronizar: true,
        ),
      );

      final actualizada = await DB.obtenerTarea(id);
      expect(actualizada!.titulo, 'Título corregido');
      expect(actualizada.descripcion, 'Nueva descripción');
      expect(actualizada.prioridad, Prioridad.alta);
    });

    test('marca una tarea como completada y la filtra', () async {
      final id = await DB.insertarTarea(nuevaTarea(titulo: 'Completar CRUD'));
      final guardada = await DB.obtenerTarea(id);

      await DB.actualizarTarea(guardada!.copiarCon(completada: true));

      expect(
        await DB.listarTareas(filtro: FiltroTareas.completadas),
        hasLength(1),
      );
      expect(await DB.listarTareas(filtro: FiltroTareas.pendientes), isEmpty);
      expect(await DB.contarTareas(completadas: true), 1);
    });

    test('elimina una tarea', () async {
      final id = await DB.insertarTarea(nuevaTarea());

      final eliminadas = await DB.eliminarTarea(id);

      expect(eliminadas, 1);
      expect(await DB.listarTareas(), isEmpty);
      expect(await DB.obtenerTarea(id), isNull);
    });

    test('busca tareas por título o descripción', () async {
      await DB.insertarTarea(nuevaTarea(titulo: 'Comprar café'));
      await DB.insertarTarea(
        nuevaTarea(titulo: 'Preparar exposición', descripcion: 'Llevar café'),
      );

      final resultados = await DB.listarTareas(busqueda: 'café');

      expect(resultados, hasLength(2));
      expect(await DB.listarTareas(busqueda: 'exposición'), hasLength(1));
    });

    test('administra la bandera pendiente_sincronizar', () async {
      await DB.insertarTarea(nuevaTarea());
      await DB.insertarTarea(nuevaTarea(titulo: 'Otra tarea'));

      expect(await DB.contarPendientesSincronizar(), 2);

      final actualizados = await DB.marcarTodoSincronizado();

      expect(actualizados, 2);
      expect(await DB.contarPendientesSincronizar(), 0);
    });

    test('los datos permanecen después de reabrir la base', () async {
      final carpeta = Directory.systemTemp.createTempSync('gestor_tareas_test');
      final ruta = p.join(carpeta.path, 'persistencia.db');

      await DB.cerrar();
      await DB.init(ruta: ruta);
      await DB.insertarTarea(nuevaTarea(titulo: 'Persistente'));
      await DB.cerrar();

      // Simula reiniciar la aplicación: se vuelve a abrir el mismo archivo.
      await DB.init(ruta: ruta);
      final tareas = await DB.listarTareas();

      expect(tareas, hasLength(1));
      expect(tareas.single.titulo, 'Persistente');

      await DB.cerrar();
      carpeta.deleteSync(recursive: true);
    });
  });

  group('CRUD de notas (ejemplo guiado)', () {
    test('inserta, actualiza y elimina notas', () async {
      final id = await DB.insertarNota('Primera nota', 'Contenido inicial');
      expect(await DB.listarNotas(), hasLength(1));

      await DB.actualizarNota(id, 'Nota editada', 'Contenido actualizado');
      final notas = await DB.listarNotas();
      expect(notas.single.titulo, 'Nota editada');
      expect(notas.single.contenido, 'Contenido actualizado');

      await DB.eliminarNota(id);
      expect(await DB.listarNotas(), isEmpty);
    });
  });
}
