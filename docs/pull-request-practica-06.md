# Pull request · Práctica 06

Título sugerido: `feat: practica 06 - persistencia local y modo offline`

Base: `develop` ← Rama: `practica-06-persistencia`

## Propósito

Incorporar persistencia local al proyecto integrador mediante SQLite y
SharedPreferences, demostrando el CRUD completo y la operación sin conexión.

## Funciones agregadas

- Base de datos `gestor_tareas.db` con las tablas `tareas` y `notas`.
- CRUD de tareas: alta con validación, consulta con búsqueda y filtros, edición,
  eliminación con confirmación y marcado de completadas.
- Preferencias persistentes: nombre del usuario y filtro seleccionado.
- Bandera `pendiente_sincronizar` y contador de cambios locales sin enviar.
- Ejemplo guiado de la práctica: pantalla de notas con CRUD en SQLite.
- Pruebas unitarias y de widgets con `sqflite_common_ffi` (18 pruebas).

## Pasos para ejecutar

```bash
flutter pub get
flutter run          # con emulador o dispositivo Android
```

## Pruebas realizadas

```text
dart format .     -> Formatted 15 files (0 changed)
flutter analyze   -> No issues found!
flutter test      -> All tests passed! (18)
```

Casos manuales:

1. Alta, edición y eliminación de tareas.
2. Filtros y búsqueda; persistencia del filtro al reiniciar.
3. Nombre de usuario conservado entre sesiones.
4. Modo avión: CRUD completo sin red y datos intactos tras reiniciar.
5. Ejemplo guiado de notas con guardar, actualizar y eliminar.

## Capturas

En [`docs/evidencias/practica-06/`](evidencias/practica-06/README.md).

## Problemas pendientes

- La sincronización real con un servidor no está implementada: la bandera
  `pendiente_sincronizar` solo registra cambios locales.
- El proyecto usa SQLite de Android/iOS; para escritorio haría falta
  `sqflite_common_ffi` en tiempo de ejecución.
