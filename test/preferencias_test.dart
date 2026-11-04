import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas/models/filtro.dart';
import 'package:gestor_tareas/preferences/preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Preferencias con SharedPreferences', () {
    test('guarda y lee el nombre del usuario', () async {
      expect(await Preferencias.leerNombre(), isNull);

      await Preferencias.guardarNombre('  Ana Martínez  ');

      expect(await Preferencias.leerNombre(), 'Ana Martínez');
    });

    test('devuelve el filtro por defecto cuando no hay valor', () async {
      expect(await Preferencias.leerFiltro(), FiltroTareas.todas);
    });

    test('guarda el filtro seleccionado', () async {
      await Preferencias.guardarFiltro(FiltroTareas.completadas);

      expect(await Preferencias.leerFiltro(), FiltroTareas.completadas);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(Preferencias.claveFiltro), 'completadas');
    });

    test('ignora filtros desconocidos y valores vacíos', () async {
      SharedPreferences.setMockInitialValues({
        Preferencias.claveFiltro: 'inventado',
        Preferencias.claveNombre: '   ',
      });

      expect(await Preferencias.leerFiltro(), FiltroTareas.todas);
      expect(await Preferencias.leerNombre(), isNull);
    });

    test('limpiar borra las preferencias guardadas', () async {
      await Preferencias.guardarNombre('Ana');
      await Preferencias.guardarFiltro(FiltroTareas.pendientes);

      await Preferencias.limpiar();

      expect(await Preferencias.leerNombre(), isNull);
      expect(await Preferencias.leerFiltro(), FiltroTareas.todas);
    });
  });
}
