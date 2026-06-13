import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpedienteProvider with ChangeNotifier {
  int? _PatientId;
  // Getter para PatientId
  int? get PatientId => _PatientId;

  // Setter para PatientId
  void setPatientId(int id) {
    _PatientId = id;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }
  int? _expedienteclinicoId;
  int? _expedienteClinico;
  String? _nit;
  String? _razonSocial;
  // Getter para expedienteclinicoId
  int? get expedienteclinicoId => _expedienteclinicoId;
  String? _documento;

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
  // Getter para razon social
  String? get razonSocial => _razonSocial;

  // Setter para razon_social
  void setrazonSocial(String? razonSocial) {
    _razonSocial = razonSocial;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }
  // Getter para documento
  String? get documento => _documento;

  // Setter para documento
  void setdocumento(String? documento) {
    _documento = documento;
    notifyListeners(); // Notifica a los widgets dependientes para que se actualicen
  }

  // Persistir la sesión en el almacenamiento local
  Future<void> guardarSesion({
    required int patientId,
    required int expedienteclinicoId,
    required int expedienteClinico,
    required String? nit,
    required String? razonSocial,
    required String? documento,
    required String? nombre,
    required String? paterno,
    required String? materno,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('patient_id', patientId);
    await prefs.setInt('expedienteclinico_id', expedienteclinicoId);
    await prefs.setInt('expediente_clinico', expedienteClinico);
    await prefs.setString('nit', nit ?? '');
    await prefs.setString('razon_social', razonSocial ?? '');
    await prefs.setString('documento', documento ?? '');
    await prefs.setString('nombre', nombre ?? '');
    await prefs.setString('paterno', paterno ?? '');
    await prefs.setString('materno', materno ?? '');

    _PatientId = patientId;
    _expedienteclinicoId = expedienteclinicoId;
    _expedienteClinico = expedienteClinico;
    _nit = nit;
    _razonSocial = razonSocial;
    _documento = documento;
    notifyListeners();
  }

  // Recuperar sesión persistida al iniciar la app
  Future<Map<String, dynamic>?> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return null;

    _PatientId = prefs.getInt('patient_id');
    _expedienteclinicoId = prefs.getInt('expedienteclinico_id');
    _expedienteClinico = prefs.getInt('expediente_clinico');
    _nit = prefs.getString('nit');
    _razonSocial = prefs.getString('razon_social');
    _documento = prefs.getString('documento');
    notifyListeners();

    return {
      'nombre': prefs.getString('nombre'),
      'paterno': prefs.getString('paterno'),
      'materno': prefs.getString('materno'),
      'ci': prefs.getString('documento'),
    };
  }

  // Limpiar sesión del almacenamiento local
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _PatientId = null;
    _expedienteclinicoId = null;
    _expedienteClinico = null;
    _nit = null;
    _razonSocial = null;
    _documento = null;
    notifyListeners();
  }
}
