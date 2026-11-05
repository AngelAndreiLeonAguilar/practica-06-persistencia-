import 'package:flutter/material.dart';

import '../models/tarea.dart';
import '../utils/formato.dart';

/// Tarjeta de una tarea dentro del listado.
class TareaTile extends StatelessWidget {
  const TareaTile({
    super.key,
    required this.tarea,
    required this.onToggle,
    required this.onEditar,
    required this.onEliminar,
  });

  final Tarea tarea;
  final VoidCallback onToggle;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  Color _colorPrioridad(BuildContext context) {
    return switch (tarea.prioridad) {
      Prioridad.alta => Colors.red.shade600,
      Prioridad.media => Colors.orange.shade800,
      Prioridad.baja => Colors.green.shade700,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colorPrioridad = _colorPrioridad(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEditar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: tarea.completada, onChanged: (_) => onToggle()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      tarea.titulo,
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: tarea.completada
                            ? TextDecoration.lineThrough
                            : null,
                        color: tarea.completada
                            ? tema.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    if (tarea.descripcion.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tarea.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorPrioridad.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Prioridad ${tarea.prioridad.etiqueta}',
                            style: tema.textTheme.labelSmall?.copyWith(
                              color: colorPrioridad,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: tema.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatearFecha(tarea.actualizadaEn),
                              style: tema.textTheme.labelSmall?.copyWith(
                                color: tema.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (tarea.pendienteSincronizar)
                          Tooltip(
                            message: 'Pendiente de sincronizar',
                            child: Icon(
                              Icons.sync,
                              size: 16,
                              color: tema.colorScheme.tertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Eliminar tarea',
                onPressed: onEliminar,
                icon: Icon(Icons.delete_outline, color: tema.colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
