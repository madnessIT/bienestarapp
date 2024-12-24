import 'package:flutter/material.dart';

class SucursalProvider with ChangeNotifier {
  String _codigo = '';
  String _descripcion = '';

  String get codigo => _codigo;
  String get descripcion => _descripcion;

  // Métodos para actualizar las variables
  void setSucursal(String codigo, String descripcion) {
    _codigo = codigo;
    _descripcion = descripcion;
    notifyListeners(); // Notificar a los widgets que están escuchando
  }

  void clearSucursal() {
    _codigo = '';
    _descripcion = '';
    notifyListeners(); // Notificar a los widgets que están escuchando
  }
}
