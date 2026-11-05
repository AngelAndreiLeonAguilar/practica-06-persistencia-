# Resultados de pruebas · Práctica 06

Fecha de ejecución: 2026-11-04
Entorno: Windows 10 (10.0.26300), Flutter 3.47.2 · Dart 3.13.2, emulador Android 16 (API 36).

## dart format .

```text
Formatted 17 files (0 changed) in 0.20 seconds.
```

## flutter analyze

```text
Analyzing Practica 6...
No issues found! (ran in 6.1s)
```

## flutter test

```text
00:05 +18: All tests passed!
```

## Prueba de integración y capturas (emulador Android)

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d emulator-5554
```

La prueba recorre el alta, edición, filtros, eliminación y notas, y guarda las
capturas en `docs/evidencias/practica-06/` (01-inicio, 02-formulario, 03-tareas,
04-filtro-pendientes, 05-completadas, 06-eliminar y 08-notas).

La corrida de verificación del 2026-11-04 finalizó con `All tests passed!` en 25 s.
En algunas ejecuciones el entorno puede mostrar además el aviso
`A SemanticsHandle was active at the end of the test`; no impide la generación de
capturas ni afecta al resultado de `flutter test`, que es el que se toma como
oficial (18/18).


Pruebas incluidas:

### `test/db_test.dart`

- Inserta y consulta tareas.
- Actualiza título, descripción y prioridad.
- Marca una tarea como completada y la filtra.
- Elimina una tarea.
- Busca por título o descripción.
- Administra la bandera `pendiente_sincronizar`.
- Los datos permanecen después de reabrir la base.
- CRUD del ejemplo guiado de notas.

### `test/widget_test.dart`

- Muestra el saludo y el estado vacío.
- Lista tareas y filtra por estado (y guarda el filtro).
- Marca una tarea como completada desde el listado.
- Abre el formulario y crea una tarea.
- Valida que el título sea obligatorio.

### `test/preferencias_test.dart`

- Guarda y lee el nombre del usuario con SharedPreferences.

## Casos manuales en emulador

| # | Caso | Resultado |
| --- | --- | --- |
| 1 | Alta de tarea con título válido | Correcto: aparece en el listado. |
| 2 | Alta con título vacío | Correcto: mensaje "El título es obligatorio". |
| 3 | Edición y cambio de prioridad | Correcto: se refleja al volver al listado. |
| 4 | Completar tarea con checkbox | Correcto: se tacha y pasa al filtro *Completadas*. |
| 5 | Eliminar con confirmación | Correcto: el diálogo permite cancelar o confirmar. |
| 6 | Cambiar filtro y reiniciar | Correcto: el filtro se restaura. |
| 7 | Cambiar nombre y reiniciar | Correcto: el saludo conserva el nombre. |
| 8 | Modo avión + CRUD | Correcto: todo funciona sin red. |
| 9 | Ejemplo de notas | Correcto: guardar, actualizar y eliminar. |
