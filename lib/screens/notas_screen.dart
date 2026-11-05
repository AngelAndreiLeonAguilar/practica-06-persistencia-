import 'package:flutter/material.dart';

import '../database/db.dart';
import '../models/nota.dart';
import '../widgets/dialogos.dart';

/// Ejemplo guiado de la práctica: notas con dos TextField y CRUD en SQLite.
class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final List<Nota> _notas = <Nota>[];

  int? _editandoId;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final notas = await DB.listarNotas();
    if (!mounted) return;
    setState(() {
      _notas
        ..clear()
        ..addAll(notas);
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final titulo = _tituloController.text.trim();
    final contenido = _contenidoController.text.trim();

    if (_editandoId == null) {
      await DB.insertarNota(titulo, contenido);
      _mostrarMensaje('Nota guardada');
    } else {
      await DB.actualizarNota(_editandoId!, titulo, contenido);
      _mostrarMensaje('Nota actualizada');
    }

    _limpiarFormulario();
    await _cargar();
  }

  void _limpiarFormulario() {
    _tituloController.clear();
    _contenidoController.clear();
    setState(() => _editandoId = null);
  }

  void _cargarParaEditar(Nota nota) {
    setState(() {
      _editandoId = nota.id;
      _tituloController.text = nota.titulo;
      _contenidoController.text = nota.contenido;
    });
    _mostrarMensaje('Editando la nota #${nota.id}');
  }

  Future<void> _eliminar(Nota nota) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar nota',
      mensaje: '¿Seguro que deseas eliminar "${nota.titulo}"?',
    );
    if (!confirmado) return;

    await DB.eliminarNota(nota.id!);
    if (_editandoId == nota.id) _limpiarFormulario();
    await _cargar();
    _mostrarMensaje('Nota eliminada');
  }

  void _mostrarMensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notas · ejemplo guiado')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editandoId == null
                                ? 'Nueva nota'
                                : 'Editando nota #$_editandoId',
                            style: tema.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _tituloController,
                            textCapitalization: TextCapitalization.sentences,
                            maxLength: 60,
                            decoration: const InputDecoration(
                              labelText: 'Título',
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              final texto = valor?.trim() ?? '';
                              if (texto.isEmpty) return 'Escribe un título';
                              if (texto.length < 3) {
                                return 'Usa al menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _contenidoController,
                            maxLines: 3,
                            maxLength: 300,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              labelText: 'Contenido',
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              if ((valor ?? '').trim().isEmpty) {
                                return 'Escribe el contenido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _guardar,
                                  icon: Icon(
                                    _editandoId == null
                                        ? Icons.save_outlined
                                        : Icons.edit_outlined,
                                  ),
                                  label: Text(
                                    _editandoId == null
                                        ? 'Guardar'
                                        : 'Actualizar',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: _limpiarFormulario,
                                child: const Text('Limpiar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notas guardadas (${_notas.length})',
                  style: tema.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                if (_notas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Todavía no hay notas. Guarda la primera arriba.',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ..._notas.map(
                    (nota) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => _cargarParaEditar(nota),
                        title: Text(
                          nota.titulo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          nota.contenido,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          tooltip: 'Eliminar nota',
                          icon: Icon(
                            Icons.delete_outline,
                            color: tema.colorScheme.error,
                          ),
                          onPressed: () => _eliminar(nota),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
