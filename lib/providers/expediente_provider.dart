// providers/expediente_provider.dart

import 'package:flutter/material.dart';
import '../models/paciente.dart';

class ExpedienteProvider with ChangeNotifier {
  Paciente? _paciente;

  Paciente? get paciente => _paciente;

  void setPaciente(Paciente paciente) {
    _paciente = paciente;
    notifyListeners();
  }

  void clearPaciente() {
    _paciente = null;
    notifyListeners();
  }
}
