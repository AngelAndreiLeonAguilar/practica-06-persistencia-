import 'package:shared_preferences/shared_preferences.dart';

import '../models/filtro.dart';

/// Persistencia de preferencias simples con SharedPreferences.
class Preferencias {
  Preferencias._();

  static const String claveNombre = 'nombre_usuario';
  static const String claveFiltro = 'filtro_tareas';

  static Future<void> guardarNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveNombre, nombre.trim());
  }

  /// Devuelve el nombre guardado o `null` si todavía no se configura.
  static Future<String?> leerNombre() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString(claveNombre)?.trim();
    if (nombre == null || nombre.isEmpty) return null;
    return nombre;
  }

  static Future<void> guardarFiltro(FiltroTareas filtro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(claveFiltro, filtro.clave);
  }

  static Future<FiltroTareas> leerFiltro() async {
    final prefs = await SharedPreferences.getInstance();
    return FiltroTareas.desdeClave(prefs.getString(claveFiltro));
  }

  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(claveNombre);
    await prefs.remove(claveFiltro);
  }
}
