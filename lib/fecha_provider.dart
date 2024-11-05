import 'package:flutter/foundation.dart';

class FechaProvider extends ChangeNotifier {
  String? _fecha;
  String? _departamentoId;

  String? get fecha => _fecha;
  String? get departamentoId => _departamentoId;

  void setFecha(String nuevaFecha) {
    _fecha = nuevaFecha;
    notifyListeners();
  }

  void setDepartamentoId(String nuevoDepartamentoId) {
    _departamentoId = nuevoDepartamentoId;
    notifyListeners();
  }
}
