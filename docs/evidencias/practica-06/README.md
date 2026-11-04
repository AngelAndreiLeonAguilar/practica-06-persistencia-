# Evidencias · Práctica 06

Capturas reales tomadas en el emulador Android (Pixel/Medium Phone, API 36) con la
aplicación **Gestor de tareas offline** en funcionamiento. Las imágenes se generaron
con la prueba de integración (`integration_test/app_test.dart`) y el driver de
captura (`test_driver/integration_test.dart`), por lo que corresponden al flujo real
de la app.

## Capturas

| Archivo | Qué demuestra |
| --- | --- |
| `01-inicio.png` | Inicio con el nombre persistido ("Hola, Ana Martínez"), filtros, contador de cambios sin sincronizar y tareas guardadas. |
| `02-formulario.png` | Formulario de alta con título, descripción, prioridad Alta y validación visible. |
| `03-tareas.png` | Listado completo con las tres tareas, prioridades y la bandera de sincronización. |
| `04-filtro-pendientes.png` | Filtro *Pendientes* seleccionado y persistido en SharedPreferences. |
| `05-completadas.png` | Filtro *Completadas* con la tarea marcada como terminada. |
| `06-eliminar.png` | Diálogo de confirmación antes de eliminar una tarea. |
| `07-modo-avion.png` | Alta/edición de tarea con el dispositivo en modo avión. |
| `08-notas.png` | Ejemplo guiado de notas con una nota guardada en SQLite. |

## Guion de demostración (modo avión)

1. Abrir la app: se muestra el saludo con el nombre guardado (`01-inicio.png`).
2. Crear tareas con distintas prioridades (`02-formulario.png`, `03-tareas.png`).
3. Cambiar el filtro a *Pendientes* (`04-filtro-pendientes.png`).
4. Marcar una tarea como completada y abrir *Completadas* (`05-completadas.png`).
5. Probar la eliminación con confirmación (`06-eliminar.png`).
6. Activar el modo avión y guardar una tarea: la app funciona sin red
   (`07-modo-avion.png`).
7. Abrir el ejemplo guiado y guardar una nota (`08-notas.png`).
8. Cerrar la app por completo y reabrirla: tareas, notas, nombre y filtro se
   conservan (persistencia verificada por las pruebas de `test/`).

## Cómo regenerar las capturas

Con un emulador o dispositivo conectado:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d emulator-5554
```

El driver guarda automáticamente los PNG en esta carpeta. También se puede usar
`adb` para una captura manual:

```bash
adb exec-out screencap -p > docs/evidencias/practica-06/01-inicio.png
```

Para un video breve:

```bash
adb shell screenrecord /sdcard/practica06.mp4
# ... interacción ...
adb pull /sdcard/practica06.mp4 docs/evidencias/practica-06/practica06.mp4
```

Si el video se publica en la nube (Drive/YouTube), agrega el enlace aquí:

- Video: _pendiente de enlace_
