import 'package:flutter/foundation.dart';

class FechaProvider with ChangeNotifier {
  String? _fecha;
  String? _departamentoId;
  String? _departamentoNombre;

  String? get fecha => _fecha;
  String? get departamentoId => _departamentoId;
  String? get departamentoNombre => _departamentoNombre;

  void setFecha(String fecha) {
    _fecha = fecha;
    notifyListeners();
  }

  void setDepartamentoId(String departamentoId) {
    _departamentoId = departamentoId;
    notifyListeners();
  }

  void setDepartamentoNombre(String departamentoNombre) {
    _departamentoNombre = departamentoNombre;
    notifyListeners();
  }
}

