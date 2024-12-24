import 'package:flutter/material.dart';

class ExpedienteProvider with ChangeNotifier {
  int? _expedienteclinicoId;
  int? _expedienteClinico;
  String? _nit;
  String? _razonSocial;
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
// Getter para nit
  String? get nit => _nit;

  // Setter para nit
  void setnit(String? nit) {
    _nit = nit;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }
// Getter para nit
  String? get razonSocial => _razonSocial;

  // Setter para razon_social
  void setrazonSocial(String? razonSocial) {
    _razonSocial = razonSocial;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }


}
