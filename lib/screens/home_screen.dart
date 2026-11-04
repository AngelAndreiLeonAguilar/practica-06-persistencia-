import 'package:flutter/material.dart';

import '../database/db.dart';
import '../models/filtro.dart';
import '../models/tarea.dart';
import '../preferences/preferencias.dart';
import '../widgets/dialogos.dart';
import '../widgets/tarea_tile.dart';
import 'notas_screen.dart';
import 'tarea_form_screen.dart';

/// Pantalla principal: gestor offline de tareas con SQLite.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _buscadorController = TextEditingController();
  final List<Tarea> _tareas = <Tarea>[];

  FiltroTareas _filtro = FiltroTareas.todas;
  String? _nombre;
  int _pendientesSincronizar = 0;
  bool _cargando = true;
  bool _preguntoNombre = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _buscadorController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final nombre = await Preferencias.leerNombre();
    final filtro = await Preferencias.leerFiltro();
    final tareas = await DB.listarTareas(
      filtro: filtro,
      busqueda: _buscadorController.text,
    );
    final pendientes = await DB.contarPendientesSincronizar();
    if (!mounted) return;

    setState(() {
      _nombre = nombre;
      _filtro = filtro;
      _tareas
        ..clear()
        ..addAll(tareas);
      _pendientesSincronizar = pendientes;
      _cargando = false;
    });

    if (nombre == null && !_preguntoNombre) {
      _preguntoNombre = true;
      await _editarNombre(inicial: true);
    }
  }

  Future<void> _editarNombre({bool inicial = false}) async {
    final nuevo = await pedirNombre(context, nombreActual: _nombre);
    if (nuevo == null) return;
    await Preferencias.guardarNombre(nuevo);
    if (!mounted) return;
    setState(() => _nombre = nuevo);
    if (!inicial) _mostrarMensaje('Nombre guardado');
  }

  Future<void> _cambiarFiltro(FiltroTareas filtro) async {
    setState(() => _filtro = filtro);
    await Preferencias.guardarFiltro(filtro);
    await _cargar();
  }

  Future<void> _abrirFormulario({Tarea? tarea}) async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TareaFormScreen(tarea: tarea)),
    );
    if (guardado == true) await _cargar();
  }

  Future<void> _alternar(Tarea tarea) async {
    await DB.actualizarTarea(
      tarea.copiarCon(
        completada: !tarea.completada,
        pendienteSincronizar: true,
        actualizadaEn: DateTime.now(),
      ),
    );
    await _cargar();
    _mostrarMensaje(
      tarea.completada ? 'Tarea marcada como pendiente' : 'Tarea completada',
    );
  }

  Future<void> _eliminar(Tarea tarea) async {
    final confirmado = await confirmarEliminacion(
      context,
      titulo: 'Eliminar tarea',
      mensaje:
          '¿Seguro que deseas eliminar "${tarea.titulo}"? Esta acción no se puede deshacer.',
    );
    if (!confirmado) return;

    await DB.eliminarTarea(tarea.id!);
    await _cargar();
    _mostrarMensaje('Tarea eliminada');
  }

  Future<void> _marcarTodoSincronizado() async {
    final cambios = await DB.marcarTodoSincronizado();
    await _cargar();
    _mostrarMensaje('$cambios cambio(s) marcados como sincronizados');
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
      appBar: AppBar(
        title: const Text('Gestor de tareas'),
        actions: [
          IconButton(
            tooltip: 'Ejemplo guiado: notas',
            icon: const Icon(Icons.sticky_note_2_outlined),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NotasScreen()));
            },
          ),
          IconButton(
            tooltip: 'Cambiar nombre',
            icon: const Icon(Icons.person_outline),
            onPressed: _editarNombre,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _encabezado(tema),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _buscadorController,
                    onChanged: (_) => _cargar(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título o descripción',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _buscadorController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpiar búsqueda',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _buscadorController.clear();
                                _cargar();
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: FiltroTareas.values.map((filtro) {
                      return ChoiceChip(
                        label: Text(filtro.etiqueta),
                        selected: _filtro == filtro,
                        onSelected: (_) => _cambiarFiltro(filtro),
                      );
                    }).toList(),
                  ),
                  if (_pendientesSincronizar > 0) ...[
                    const SizedBox(height: 12),
                    Card(
                      color: tema.colorScheme.tertiaryContainer,
                      child: ListTile(
                        leading: Icon(
                          Icons.sync_problem,
                          color: tema.colorScheme.onTertiaryContainer,
                        ),
                        title: Text(
                          '$_pendientesSincronizar cambio(s) sin sincronizar',
                          style: TextStyle(
                            color: tema.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Guardados localmente; se enviarán al recuperar conexión.',
                          style: TextStyle(
                            color: tema.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: _marcarTodoSincronizado,
                          child: const Text('Marcar enviados'),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_tareas.isEmpty)
                    _estadoVacio(tema)
                  else
                    ..._tareas.map(
                      (tarea) => TareaTile(
                        tarea: tarea,
                        onToggle: () => _alternar(tarea),
                        onEditar: () => _abrirFormulario(tarea: tarea),
                        onEliminar: () => _eliminar(tarea),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Datos almacenados en SQLite · ${_tareas.length} tarea(s) '
                    'en la vista "${_filtro.etiqueta}"',
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

  Widget _encabezado(ThemeData tema) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: tema.colorScheme.primary,
                child: Icon(Icons.person, color: tema.colorScheme.onPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${_nombre ?? 'Invitado'}',
                      style: tema.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Tus tareas viven en este dispositivo',
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                avatar: const Icon(Icons.cloud_off, size: 16),
                label: const Text('Modo offline'),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                avatar: const Icon(Icons.storage, size: 16),
                label: const Text('SQLite + preferencias'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio(ThemeData tema) {
    final (titulo, mensaje) = switch (_filtro) {
      FiltroTareas.todas => (
        'Aún no hay tareas',
        'Toca "Nueva tarea" para guardar la primera.',
      ),
      FiltroTareas.pendientes => (
        'No hay tareas pendientes',
        'Buen trabajo: todo está completado.',
      ),
      FiltroTareas.completadas => (
        'No hay tareas completadas',
        'Marca una tarea con el checkbox para verla aquí.',
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.task_alt,
            size: 56,
            color: tema.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(titulo, style: tema.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
