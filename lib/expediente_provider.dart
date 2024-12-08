import 'package:flutter/material.dart';

class ExpedienteProvider with ChangeNotifier {
  int? _expedienteclinicoId;
  int? _expedienteClinico;

  // Getter para expedienteclinicoId
  int? get expedienteclinicoId => _expedienteclinicoId;

  // Setter para expedienteclinicoId
  void setExpedienteclinicoId(int id) {
    _expedienteclinicoId = id;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }

  // Getter para expedienteClinico
  int? get expedienteClinico => _expedienteClinico;

  // Setter para expedienteClinico
  void setExpedienteClinico(int expedienteClinico) {
    _expedienteClinico = expedienteClinico;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }
}
