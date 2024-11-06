import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModifyPage extends StatefulWidget {
  const ModifyPage({super.key});

  @override
  _ModifyPageState createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _domicilioController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? modifyStatus;
  String? patientId; // ID del paciente encontrado para modificar
  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/';

  // Método para buscar paciente (ahora usando POST)
  Future<void> searchPatient() async {
    var url = Uri.parse(apiUrl);

    Map<String, String> data = {
      'documento': _searchController.text,
    };

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          patientId = data['id'].toString();
          _nombresController.text = data['nombres'];
          _paternoController.text = data['paterno'];
          _maternoController.text = data['materno'];
          _fechaNacimientoController.text = data['fecha_nacimiento'];
          _domicilioController.text = data['domicilio'];
          _documentoController.text = data['documento'];
          _sexoController.text = data['sexo'];
          _celularController.text = data['celular'].toString();
          _emailController.text = data['expedienteclinico']['email'] ?? '';
        });
      } else {
        setState(() {
          modifyStatus = 'Paciente no encontrado. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        modifyStatus = 'Error en la conexión';
      });
    }
  }

  // Método para modificar datos del paciente
  Future<void> modifyPatient() async {
    if (patientId == null) return;

    var url = Uri.parse('$apiUrl$patientId/');
    Map<String, dynamic> data = {
      "fecha_nacimiento": _fechaNacimientoController.text,
      "nombres": _nombresController.text,
      "paterno": _paternoController.text,
      "materno": _maternoController.text,
      "domicilio": _domicilioController.text,
      "documento": _documentoController.text,
      "sexo": _sexoController.text,
      "celular": _celularController.text,
      "expedienteclinico": {
        "email": _emailController.text,
      }
    };

    try {
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'regional': '1',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          modifyStatus = 'Datos del paciente modificados con éxito.';
        });
      } else {
        setState(() {
          modifyStatus = 'Error al modificar datos: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        modifyStatus = 'Error en la conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar Paciente"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const Text(
              'Buscar Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Documento de Identidad',
              ),
            ),
            ElevatedButton(
              onPressed: searchPatient,
              child: const Text("Buscar"),
            ),
            const Divider(height: 30),
            const Text(
              'Modificar Datos del Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _nombresController,
              decoration: const InputDecoration(labelText: 'Nombres'),
            ),
            TextField(
              controller: _paternoController,
              decoration: const InputDecoration(labelText: 'Apellido Paterno'),
            ),
            TextField(
              controller: _maternoController,
              decoration: const InputDecoration(labelText: 'Apellido Materno'),
            ),
            TextField(
              controller: _fechaNacimientoController,
              decoration: const InputDecoration(labelText: 'Fecha de Nacimiento (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _domicilioController,
              decoration: const InputDecoration(labelText: 'Domicilio'),
            ),
            TextField(
              controller: _documentoController,
              decoration: const InputDecoration(labelText: 'Documento de Identidad'),
            ),
            TextField(
              controller: _sexoController,
              decoration: const InputDecoration(labelText: 'Sexo (MA/FE)'),
            ),
            TextField(
              controller: _celularController,
              decoration: const InputDecoration(labelText: 'Celular'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: modifyPatient,
              child: const Text("Guardar Cambios"),
            ),
            const SizedBox(height: 20),
            modifyStatus != null
                ? Text(
                    modifyStatus!,
                    style: TextStyle(
                      color: modifyStatus!.contains('éxito') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
