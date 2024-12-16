import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EspecialidadProvider with ChangeNotifier {
  List<Map<String, dynamic>> especialidades = [];
  List<String> codigos = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get getEspecialidades => especialidades;
  List<String> get getCodigos => codigos;

  // Método para cargar especialidades y códigos
  Future<void> fetchEspecialidadesYCodigos(String fecha, String departamentoId) async {
    _isLoading = true;
    notifyListeners();

    // Llamada a la API para obtener especialidades
    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/administracion/servicios_by_departamento_fecha/?fecha=$fecha&departamento_id=$departamentoId',
    );
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        especialidades = (data as List).map((item) {
          return {
            'especialidad_id': item['id'],
            'especialidad_nombre': item['nombre'],
          };
        }).toList();
      } else {
        print('Error al obtener especialidades: ${response.statusCode}');
      }

      // Llamada a la API para obtener códigos
      url = Uri.parse(
        'http://test.api.movil.cies.org.bo/agenda/regionales_internet/?especialidad=26&departamento=$departamentoId&fecha=$fecha',
      );
      response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        codigos = List<String>.from(data.map((item) => item['codigo'].toString()));
      } else {
        print('Error al obtener códigos: ${response.statusCode}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error en la conexión: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
