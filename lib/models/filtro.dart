/// Filtros de la lista de tareas que se conservan con SharedPreferences.
enum FiltroTareas {
  todas('todas', 'Todas'),
  pendientes('pendientes', 'Pendientes'),
  completadas('completadas', 'Completadas');

  const FiltroTareas(this.clave, this.etiqueta);

  /// Valor que se guarda en SharedPreferences.
  final String clave;

  /// Texto que se muestra en la interfaz.
  final String etiqueta;

  static FiltroTareas desdeClave(String? clave) {
    return FiltroTareas.values.firstWhere(
      (filtro) => filtro.clave == clave,
      orElse: () => FiltroTareas.todas,
    );
  }
}
