/// Prioridad de una tarea.
enum Prioridad {
  baja('baja', 'Baja'),
  media('media', 'Media'),
  alta('alta', 'Alta');

  const Prioridad(this.clave, this.etiqueta);

  final String clave;
  final String etiqueta;

  static Prioridad desdeClave(String? clave) {
    return Prioridad.values.firstWhere(
      (prioridad) => prioridad.clave == clave,
      orElse: () => Prioridad.media,
    );
  }
}

/// Entidad principal del proyecto integrador: una tarea guardada en SQLite.
class Tarea {
  const Tarea({
    this.id,
    required this.titulo,
    this.descripcion = '',
    this.prioridad = Prioridad.media,
    this.completada = false,
    this.pendienteSincronizar = true,
    required this.creadaEn,
    required this.actualizadaEn,
  });

  final int? id;
  final String titulo;
  final String descripcion;
  final Prioridad prioridad;
  final bool completada;

  /// Bandera local que marca cambios que todavía no se envían a un servidor.
  final bool pendienteSincronizar;
  final DateTime creadaEn;
  final DateTime actualizadaEn;

  Tarea copiarCon({
    int? id,
    String? titulo,
    String? descripcion,
    Prioridad? prioridad,
    bool? completada,
    bool? pendienteSincronizar,
    DateTime? creadaEn,
    DateTime? actualizadaEn,
  }) {
    return Tarea(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      completada: completada ?? this.completada,
      pendienteSincronizar: pendienteSincronizar ?? this.pendienteSincronizar,
      creadaEn: creadaEn ?? this.creadaEn,
      actualizadaEn: actualizadaEn ?? this.actualizadaEn,
    );
  }

  factory Tarea.desdeMapa(Map<String, Object?> mapa) {
    final creada = DateTime.tryParse(mapa['creada_en'] as String? ?? '');
    final actualizada = DateTime.tryParse(
      mapa['actualizada_en'] as String? ?? '',
    );
    return Tarea(
      id: mapa['id'] as int?,
      titulo: mapa['titulo'] as String? ?? '',
      descripcion: mapa['descripcion'] as String? ?? '',
      prioridad: Prioridad.desdeClave(mapa['prioridad'] as String?),
      completada: (mapa['completada'] as int? ?? 0) == 1,
      pendienteSincronizar: (mapa['pendiente_sincronizar'] as int? ?? 1) == 1,
      creadaEn: creada ?? DateTime.now(),
      actualizadaEn: actualizada ?? creada ?? DateTime.now(),
    );
  }

  Map<String, Object?> aMapa({bool incluirId = true}) {
    return <String, Object?>{
      if (incluirId && id != null) 'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'prioridad': prioridad.clave,
      'completada': completada ? 1 : 0,
      'pendiente_sincronizar': pendienteSincronizar ? 1 : 0,
      'creada_en': creadaEn.toIso8601String(),
      'actualizada_en': actualizadaEn.toIso8601String(),
    };
  }
}
