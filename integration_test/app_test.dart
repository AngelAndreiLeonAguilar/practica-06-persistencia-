import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas/database/db.dart';
import 'package:gestor_tareas/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recorre el flujo completo en un dispositivo real y captura evidencias.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    bool presente = true,
  }) async {
    for (var intento = 0; intento < 60; intento++) {
      if (finder.evaluate().isNotEmpty == presente) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('No se cumplió la espera de $finder (presente: $presente)');
  }

  Future<void> crearTarea(
    WidgetTester tester, {
    required String titulo,
    required String descripcion,
    required String prioridad,
  }) async {
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await esperar(tester, find.text('Título de la tarea'));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título de la tarea'),
      titulo,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción (opcional)'),
      descripcion,
    );
    await tester.tap(find.text(prioridad));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar tarea'));
    await esperar(tester, find.text('Guardar tarea'), presente: false);
    await esperar(tester, find.text(titulo));
    await tester.pumpAndSettle();
  }

  testWidgets('flujo completo: nombre, CRUD, filtros, offline y notas', (
    tester,
  ) async {
    await DB.cerrar();
    await DB.init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Deja la base limpia para que la evidencia sea reproducible.
    final db = await DB.database;
    await db.delete('tareas');
    await db.delete('notas');

    await tester.pumpWidget(const GestorTareasApp());
    await tester.pumpAndSettle();

    // 1. Nombre del usuario (SharedPreferences).
    await esperar(tester, find.text('¿Cómo te llamas?'));
    await tester.enterText(find.byType(TextFormField), 'Ana Martínez');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    await esperar(tester, find.text('Hola, Ana Martínez'));

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01-inicio');

    // 2. Formulario de alta.
    await tester.tap(find.text('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título de la tarea'),
      'Entregar práctica 6',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción (opcional)'),
      'Subir el repositorio y las evidencias',
    );
    await tester.tap(find.text('Alta'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02-formulario');

    await tester.tap(find.text('Guardar tarea'));
    await esperar(tester, find.text('Guardar tarea'), presente: false);
    await esperar(tester, find.text('Entregar práctica 6'));

    // 3. Más tareas para el listado.
    await crearTarea(
      tester,
      titulo: 'Estudiar SQLite',
      descripcion: 'Repasar INSERT, UPDATE y DELETE',
      prioridad: 'Media',
    );
    await crearTarea(
      tester,
      titulo: 'Comprar café',
      descripcion: 'Para la sesión de estudio',
      prioridad: 'Baja',
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('03-tareas');

    // 4. Filtro persistente de pendientes.
    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04-filtro-pendientes');

    // 5. Marcar como completada y ver el filtro de completadas.
    final tarjetaEntregar = find.ancestor(
      of: find.text('Entregar práctica 6'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(of: tarjetaEntregar, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Completadas'));
    await tester.pumpAndSettle();
    await esperar(tester, find.text('Entregar práctica 6'));
    await binding.takeScreenshot('05-completadas');

    // 6. Diálogo de confirmación para eliminar.
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await esperar(tester, find.text('Eliminar tarea'));
    await binding.takeScreenshot('06-eliminar');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // 7. Ejemplo guiado de notas.
    await tester.tap(find.byIcon(Icons.sticky_note_2_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Recordatorio',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contenido'),
      'Las notas también se guardan sin conexión.',
    );
    await tester.tap(find.text('Guardar'));
    await esperar(tester, find.text('Recordatorio'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('08-notas');
  });
}
