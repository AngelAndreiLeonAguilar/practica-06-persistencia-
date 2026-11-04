# Práctica 06 · Persistencia local y funcionamiento offline

Gestor de tareas **offline** desarrollado en Flutter para la Práctica 6. La aplicación
guarda sus datos en SQLite (`sqflite`) y recuerda las preferencias del usuario con
`shared_preferences`, por lo que el CRUD completo sigue funcionando sin conexión a
Internet y los datos sobreviven al reinicio de la app o del dispositivo.

## Objetivo

Demostrar la persistencia local de registros estructurados y de preferencias simples:

- CRUD de tareas (crear, consultar, editar, eliminar) en SQLite.
- Marcar tareas como completadas y filtrarlas por estado.
- Preferencia de interfaz persistente (nombre del usuario y filtro seleccionado).
- Operación sin conexión (modo avión) con una bandera `pendiente_sincronizar`
  que identifica cambios locales aún no enviados a un servidor.
- Ejemplo guiado de la práctica (notas con SQLite) accesible desde la pantalla
  principal.

## Funcionalidades

| Función | Descripción |
| --- | --- |
| Alta de tareas | Formulario con título obligatorio, descripción, prioridad y estado. |
| Listado y búsqueda | Lista ordenada (pendientes primero) y búsqueda por título o descripción. |
| Filtros | Todas, pendientes y completadas; el filtro se recuerda entre sesiones. |
| Edición | Al tocar una tarjeta se abre el formulario con los datos cargados. |
| Eliminación | Botón de papelera con diálogo de confirmación. |
| Completar | Checkbox que actualiza el estado en SQLite al instante. |
| Nombre de usuario | Se solicita al primer inicio y se muestra como saludo; se guarda en SharedPreferences. |
| Bandera offline | `pendiente_sincronizar` se activa en cada alta/edición y se muestra en la UI. |
| Ejemplo guiado | Pantalla de notas con dos `TextField`, Guardar/Actualizar, edición al tocar y eliminación con confirmación. |

## Requisitos

- Flutter 3.47 o superior (Dart 3.13 o superior).
- Android SDK y un emulador o dispositivo Android (la app usa `sqflite`, que requiere
  Android/iOS; en escritorio se necesitaría `sqflite_common_ffi`).
- Git para el control de versiones.

Verifica el entorno con:

```bash
flutter doctor
flutter devices
```

## Instalación

```bash
git clone <URL-del-repositorio>
cd practica-06-persistencia
flutter pub get
```

Dependencias principales (ya declaradas en `pubspec.yaml`):

```yaml
shared_preferences: ^2.5.6
sqflite: ^2.4.5
path: ^1.9.1
```

## Ejecución

Con un emulador o dispositivo conectado:

```bash
flutter run
```

Para comprobar la operación offline:

1. Abre la app y crea dos o tres tareas.
2. Activa el **modo avión** del dispositivo (o desactiva Wi-Fi y datos).
3. Crea, edita, completa y elimina tareas: todo sigue funcionando.
4. Cierra la app por completo y vuelve a abrirla: las tareas y el nombre se conservan.
5. Cambia el filtro a *Completadas*, cierra la app y vuelve a abrirla: el filtro
   seleccionado se restaura.

## Estructura del proyecto

```text
lib/
├── database/db.dart            # Acceso a SQLite, tablas tareas y notas
├── models/
│   ├── tarea.dart              # Entidad Tarea + enum Prioridad
│   ├── nota.dart               # Entidad del ejemplo guiado
│   └── filtro.dart             # Enum de filtros persistidos
├── preferences/preferencias.dart  # SharedPreferences (nombre y filtro)
├── screens/
│   ├── home_screen.dart        # Listado, búsqueda, filtros y bandera offline
│   ├── tarea_form_screen.dart  # Alta y edición con validación
│   └── notas_screen.dart       # Ejemplo guiado de la práctica
├── widgets/
│   ├── tarea_tile.dart         # Tarjeta de tarea
│   └── dialogos.dart           # Diálogos de nombre y confirmación
├── utils/formato.dart          # Formato de fechas
└── main.dart                   # Punto de entrada
test/
├── db_test.dart                # CRUD, filtros, búsqueda, persistencia y notas
├── preferencias_test.dart      # Lectura/escritura de SharedPreferences
└── widget_test.dart            # Flujos de interfaz con SQLite real (FFI)
integration_test/
└── app_test.dart               # Flujo completo en emulador + capturas
test_driver/
└── integration_test.dart       # Driver que guarda las capturas en docs/
```

### Esquema SQLite (`gestor_tareas.db`)

```sql
CREATE TABLE notas(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo TEXT NOT NULL,
  contenido TEXT NOT NULL
);

CREATE TABLE tareas(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo TEXT NOT NULL,
  descripcion TEXT NOT NULL DEFAULT '',
  prioridad TEXT NOT NULL DEFAULT 'media',
  completada INTEGER NOT NULL DEFAULT 0,
  pendiente_sincronizar INTEGER NOT NULL DEFAULT 1,
  creada_en TEXT NOT NULL,
  actualizada_en TEXT NOT NULL
);
```

## Pruebas

```bash
dart format .
flutter analyze
flutter test
```

Resultados de la última ejecución en este equipo:

- `dart format .` → `Formatted 17 files (0 changed)`.
- `flutter analyze` → `No issues found!`.
- `flutter test` → `All tests passed!` (18 pruebas).

Las pruebas usan `sqflite_common_ffi` para ejecutar SQLite real en el runner de
Dart, sin necesidad de emulador.

Prueba de integración en emulador (genera las capturas de evidencia):

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d emulator-5554
```

La corrida de verificación terminó con `All tests passed!` y genera las capturas
de `docs/evidencias/practica-06/` mediante el driver.

## Evidencias

Las capturas y la guía de demostración están en
[`docs/evidencias/practica-06/`](docs/evidencias/practica-06/README.md).

## Entrega en GitHub

- Repositorio: <https://github.com/AngelAndreiLeonAguilar/practica-06-persistencia->
- Rama de la práctica: `practica-06-persistencia` (parte de `develop`).
- Pull request: <https://github.com/AngelAndreiLeonAguilar/practica-06-persistencia-/pull/1>
- Commit de la entrega: <https://github.com/AngelAndreiLeonAguilar/practica-06-persistencia-/commit/c863781>
- No se versionan `.dart_tool`, `build`, credenciales, llaves ni archivos generados.

El texto completo de la pull request está en
[`docs/pull-request-practica-06.md`](docs/pull-request-practica-06.md).

Comandos utilizados para publicar la entrega:

```bash
git remote add origin https://github.com/AngelAndreiLeonAguilar/practica-06-persistencia-.git
git push -u origin develop
git push -u origin practica-06-persistencia
```

La pull request se abrió desde `practica-06-persistencia` hacia `develop` con
propósito, funciones agregadas, pasos para ejecutar, pruebas realizadas, capturas
y problemas pendientes.

## Participantes

- Angel Andrei Leon Aguilar

## Referencias

- Flutter · Persistence cookbook: <https://docs.flutter.dev/cookbook/persistence>
- `sqflite`: <https://pub.dev/packages/sqflite>
- `shared_preferences`: <https://pub.dev/packages/shared_preferences>
