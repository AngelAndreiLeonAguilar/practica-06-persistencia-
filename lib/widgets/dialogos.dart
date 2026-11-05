import 'package:flutter/material.dart';

/// Diálogo para capturar o cambiar el nombre del usuario.
Future<String?> pedirNombre(BuildContext context, {String? nombreActual}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _DialogoNombre(nombreActual: nombreActual),
  );
}

class _DialogoNombre extends StatefulWidget {
  const _DialogoNombre({this.nombreActual});

  final String? nombreActual;

  @override
  State<_DialogoNombre> createState() => _DialogoNombreState();
}

class _DialogoNombreState extends State<_DialogoNombre> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.nombreActual ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Cómo te llamas?'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: 'Nombre del usuario',
            hintText: 'Ej. Ana Martínez',
            border: OutlineInputBorder(),
          ),
          validator: (valor) {
            if (valor == null || valor.trim().isEmpty) {
              return 'Escribe tu nombre';
            }
            if (valor.trim().length < 2) {
              return 'Usa al menos 2 caracteres';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ahora no'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_controller.text.trim());
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Diálogo de confirmación para eliminar registros.
Future<bool> confirmarEliminacion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
  return confirmado ?? false;
}
