import 'package:flutter/material.dart';

import '../database/db.dart';
import '../models/tarea.dart';

/// Formulario de alta y edición de tareas.
class TareaFormScreen extends StatefulWidget {
  const TareaFormScreen({super.key, this.tarea});

  final Tarea? tarea;

  bool get esEdicion => tarea != null;

  @override
  State<TareaFormScreen> createState() => _TareaFormScreenState();
}

class _TareaFormScreenState extends State<TareaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  late Prioridad _prioridad;
  late bool _completada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final tarea = widget.tarea;
    _tituloController = TextEditingController(text: tarea?.titulo ?? '');
    _descripcionController = TextEditingController(
      text: tarea?.descripcion ?? '',
    );
    _prioridad = tarea?.prioridad ?? Prioridad.media;
    _completada = tarea?.completada ?? false;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _guardando = true);
    final ahora = DateTime.now();
    final original = widget.tarea;

    try {
      if (original == null) {
        await DB.insertarTarea(
          Tarea(
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            prioridad: _prioridad,
            completada: _completada,
            creadaEn: ahora,
            actualizadaEn: ahora,
          ),
        );
      } else {
        await DB.actualizarTarea(
          original.copiarCon(
            titulo: _tituloController.text.trim(),
            descripcion: _descripcionController.text.trim(),
            prioridad: _prioridad,
            completada: _completada,
            pendienteSincronizar: true,
            actualizadaEn: ahora,
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la tarea: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final editando = widget.esEdicion;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar tarea' : 'Nueva tarea')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              autofocus: !editando,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
                hintText: 'Ej. Entregar práctica 6',
                prefixIcon: Icon(Icons.task_alt),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                final texto = valor?.trim() ?? '';
                if (texto.isEmpty) return 'El título es obligatorio';
                if (texto.length < 3) {
                  return 'Usa al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionController,
              maxLength: 300,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles, materiales o recordatorios',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if ((valor ?? '').trim().length > 300) {
                  return 'Máximo 300 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text('Prioridad', style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Prioridad>(
              segments: Prioridad.values
                  .map(
                    (prioridad) => ButtonSegment<Prioridad>(
                      value: prioridad,
                      label: Text(prioridad.etiqueta),
                    ),
                  )
                  .toList(),
              selected: {_prioridad},
              onSelectionChanged: (seleccion) {
                setState(() => _prioridad = seleccion.first);
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Tarea completada'),
                subtitle: const Text('Se guarda el estado en SQLite'),
                value: _completada,
                onChanged: (valor) => setState(() => _completada = valor),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(editando ? Icons.save : Icons.add_task),
              label: Text(editando ? 'Actualizar tarea' : 'Guardar tarea'),
            ),
            const SizedBox(height: 12),
            Text(
              'Los datos se guardan en el dispositivo y funcionan sin conexión.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
