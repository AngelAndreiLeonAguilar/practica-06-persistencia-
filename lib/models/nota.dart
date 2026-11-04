/// Nota del ejemplo guiado (Parte A y B de la práctica).
class Nota {
  const Nota({this.id, required this.titulo, required this.contenido});

  final int? id;
  final String titulo;
  final String contenido;

  factory Nota.desdeMapa(Map<String, Object?> mapa) {
    return Nota(
      id: mapa['id'] as int?,
      titulo: mapa['titulo'] as String? ?? '',
      contenido: mapa['contenido'] as String? ?? '',
    );
  }

  Map<String, Object?> aMapa({bool incluirId = true}) {
    return <String, Object?>{
      if (incluirId && id != null) 'id': id,
      'titulo': titulo,
      'contenido': contenido,
    };
  }
}
