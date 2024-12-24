import 'package:flutter/foundation.dart';

class ServicioProvider with ChangeNotifier {
  String _servicioNombre = '';
  String _servicioCodigo = '';

  // Getters para acceder a los valores
  String get servicioNombre => _servicioNombre;
  String get servicioCodigo => _servicioCodigo;

  // Setters para actualizar los valores
  void setServicioNombre(String nombre) {
    _servicioNombre = nombre;
    notifyListeners(); // Notifica a los widgets interesados
  }

  void setServicioCodigo(String codigo) {
    _servicioCodigo = codigo;
    notifyListeners(); // Notifica a los widgets interesados
  }

  // Método para configurar ambos valores
  void setServicio(String nombre, String codigo) {
    _servicioNombre = nombre;
    _servicioCodigo = codigo;
    notifyListeners();
  }
}
