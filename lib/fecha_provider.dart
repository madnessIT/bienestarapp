import 'package:flutter/material.dart';

class FechaProvider with ChangeNotifier {
  DateTime? _fecha;

  DateTime? get fecha => _fecha;

  void setFecha(DateTime nuevaFecha) {
    _fecha = nuevaFecha;
    notifyListeners(); // Notifica a los widgets que están escuchando cuando cambia la fecha
  }
}
