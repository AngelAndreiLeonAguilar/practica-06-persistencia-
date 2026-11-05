import 'package:flutter/material.dart';

import 'database/db.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(const GestorTareasApp());
}

/// Aplicación del proyecto integrador: gestor offline de tareas.
class GestorTareasApp extends StatelessWidget {
  const GestorTareasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final esquema = ColorScheme.fromSeed(seedColor: const Color(0xFF00695C));

    return MaterialApp(
      title: 'Gestor de tareas offline',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: esquema,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: esquema.surfaceContainer,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
