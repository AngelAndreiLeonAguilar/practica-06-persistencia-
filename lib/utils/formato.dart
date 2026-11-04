/// Formatea una fecha como `dd/MM/yyyy HH:mm` sin depender de paquetes extra.
String formatearFecha(DateTime fecha) {
  String dosDigitos(int valor) => valor.toString().padLeft(2, '0');
  return '${dosDigitos(fecha.day)}/${dosDigitos(fecha.month)}/${fecha.year} '
      '${dosDigitos(fecha.hour)}:${dosDigitos(fecha.minute)}';
}
