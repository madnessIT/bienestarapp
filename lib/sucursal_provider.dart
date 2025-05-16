import 'package:flutter/material.dart';

class SucursalProvider with ChangeNotifier {
  String _id = '';
  String _codigo = '';
  String _descripcion = '';

  String get id => _id;
  String get codigo => _codigo;
  String get descripcion => _descripcion;

  // Métodos para actualizar las variables
  void setSucursal(String codigo, String descripcion, String id) {
    _id = id;
    _codigo = codigo;
    _descripcion = descripcion;
    notifyListeners(); // Notificar a los widgets que están escuchando
  }

  void clearSucursal() {    
    _id = '';
    _codigo = '';
    _descripcion = '';
    notifyListeners(); // Notificar a los widgets que están escuchando
  }
}
