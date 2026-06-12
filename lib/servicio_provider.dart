import 'package:flutter/foundation.dart';

class ServicioProvider with ChangeNotifier {
  String _servicioId = '';
  String _servicioNombre = '';
  String _servicioCodigo = '';

  // Getters para acceder a los valores
  String get servicioId => _servicioId;
  String get servicioNombre => _servicioNombre;
  String get servicioCodigo => _servicioCodigo;

  // Setters para actualizar los valores
  
  void setServicioId(String id) {
    _servicioId = id;
    notifyListeners(); // Notifica a los widgets interesados
  }
  void setServicioNombre(String nombre) {
    _servicioNombre = nombre;
    notifyListeners(); // Notifica a los widgets interesados
  }

  void setServicioCodigo(String codigo) {
    _servicioCodigo = codigo;
    notifyListeners(); // Notifica a los widgets interesados
  }

  // Método para configurar ambos valores
  void setServicio(String nombre, String codigo, String id) {
    _servicioNombre = nombre;
    _servicioCodigo = codigo;
    _servicioId = id; // Asignar el mismo valor a servicioId
    notifyListeners();
  }

  // --- Manejo del Carrito de Servicios ---
  final List<Map<String, dynamic>> _serviciosCarrito = [];

  List<Map<String, dynamic>> get serviciosCarrito => _serviciosCarrito;

  void agregarServicioAlCarrito(Map<String, dynamic> item) {
    _serviciosCarrito.add(item);
    notifyListeners();
  }

  void eliminarServicioDelCarrito(int index) {
    if (index >= 0 && index < _serviciosCarrito.length) {
      _serviciosCarrito.removeAt(index);
      notifyListeners();
    }
  }

  void limpiarCarrito() {
    _serviciosCarrito.clear();
    notifyListeners();
  }
}
