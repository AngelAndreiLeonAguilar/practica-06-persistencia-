import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas/database/db.dart';
import 'package:gestor_tareas/main.dart';
import 'package:gestor_tareas/models/filtro.dart';
import 'package:gestor_tareas/models/tarea.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'nombre_usuario': 'Ana'});
    await DB.cerrar();
    await DB.init(ruta: inMemoryDatabasePath);
  });

  tearDown(() async {
    await DB.cerrar();
  });

  Future<void> sembrarTareas() async {
    final ahora = DateTime(2026, 11, 4, 12, 30);
    await DB.insertarTarea(
      Tarea(titulo: 'Entregar práctica', creadaEn: ahora, actualizadaEn: ahora),
    );
    await DB.insertarTarea(
      Tarea(
        titulo: 'Estudiar SQLite',
        completada: true,
        creadaEn: ahora,
        actualizadaEn: ahora,
      ),
    );
  }

  /// Monta la app y espera a que SQLite responda (usa IO real).
  Future<void> montarApp(WidgetTester tester) async {
    await tester.pumpWidget(const GestorTareasApp());
    for (var intento = 0; intento < 20; intento++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  /// Deja correr las operaciones asíncronas pendientes y repinta.
  Future<void> refrescar(WidgetTester tester) async {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  /// Espera (con IO real) hasta que se cumpla una condición de la interfaz.
  Future<void> esperar(
    WidgetTester tester,
    bool Function() condicion, {
    required String descripcion,
  }) async {
    for (var intento = 0; intento < 60; intento++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (condicion()) {
        await tester.pumpAndSettle();
        return;
      }
    }
    throw TestFailure('Tiempo de espera agotado: $descripcion');
  }

  testWidgets('muestra el saludo y el estado vacío', (tester) async {
    await montarApp(tester);

    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(find.text('Aún no hay tareas'), findsOneWidget);
    expect(find.text('Nueva tarea'), findsOneWidget);
  });

  testWidgets('lista las tareas guardadas y filtra por estado', (tester) async {
    await tester.runAsync(sembrarTareas);
    await montarApp(tester);

    expect(find.text('Entregar práctica'), findsOneWidget);
    expect(find.text('Estudiar SQLite'), findsOneWidget);

    await tester.tap(find.text('Pendientes'));
    await esperar(
      tester,
      () => find.text('Estudiar SQLite').evaluate().isEmpty,
      descripcion: 'aplicar el filtro de pendientes',
    );

    expect(find.text('Entregar práctica'), findsOneWidget);
    expect(find.text('Estudiar SQLite'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('filtro_tareas'), FiltroTareas.pendientes.clave);
  });

  testWidgets('marca una tarea como completada desde el listado', (
    tester,
  ) async {
    await tester.runAsync(sembrarTareas);
    await montarApp(tester);

    await tester.tap(find.byType(Checkbox).first);
    await refrescar(tester);

    final completadas = await tester.runAsync(
      () => DB.listarTareas(filtro: FiltroTareas.completadas),
    );
    expect(completadas, hasLength(2));
  });

  testWidgets('abre el formulario y crea una tarea', (tester) async {
    await montarApp(tester);

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Título de la tarea'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título de la tarea'),
      'Comprar café',
    );
    await tester.tap(find.text('Guardar tarea'));
    await esperar(
      tester,
      () =>
          find.text('Guardar tarea').evaluate().isEmpty &&
          find.text('Comprar café').evaluate().isNotEmpty,
      descripcion: 'mostrar la tarea creada en el listado',
    );

    expect(find.text('Comprar café'), findsOneWidget);

    final tareas = await tester.runAsync(DB.listarTareas);
    expect(tareas!.single.titulo, 'Comprar café');
  });

  testWidgets('valida que el título sea obligatorio', (tester) async {
    await montarApp(tester);

    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('El título es obligatorio'), findsOneWidget);
    final tareas = await tester.runAsync(DB.listarTareas);
    expect(tareas, isEmpty);
  });
}
