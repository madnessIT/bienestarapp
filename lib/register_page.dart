import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _fechaNacimientoController = TextEditingController();
  final TextEditingController _domicilioController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? registroStatus;

  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/';

  Future<void> registrarPaciente() async {
    var url = Uri.parse(apiUrl);

     Map<String, dynamic> data = {
      "fecha_nacimiento": _fechaNacimientoController.text,
      "nombres": _nombresController.text,
      "paterno": _paternoController.text,
      "materno": _maternoController.text,
      "expedido": 1,  // Ejemplo
      "domicilio": _domicilioController.text,
      "documento": _documentoController.text,
      "sexo": "MA",  // Valor ejemplo
      "tipo_documento": "CIN",
      "estadocivil": 1,
      "celular": _celularController.text,
      "asegurado_aux":null,
      "expedienteclinico": {
        "telefono": _celularController.text,
        "email": _emailController.text,
        "procedencia_pais": 1,
        "procedencia_departamento": 1,
        "residencia_pais": 1,
        "residencia_departamento": 1,
        "residencia_municipio": 1,
        "estado_civil": 1,
        "nivel_instruccion": 1,
        "ocupacion": 1,
        "idioma_materno":1,
        "idioma_hablado": 1, 
        "etnia":1,
        "referencia":1,
        "identidad_genero": 1,
        "orientacion_sexual" :null,
        "regional":2
      }
    };

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'regional': '1',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          registroStatus = 'Paciente registrado con éxito.';
        });
      } else {
        setState(() {
          registroStatus = 'Error al registrar paciente: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        registroStatus = 'Error en la conexión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Pacientes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
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
              onPressed: registrarPaciente,
              child: const Text("Registrar Paciente"),
            ),
            const SizedBox(height: 20),
            registroStatus != null
                ? Text(
                    registroStatus!,
                    style: TextStyle(
                      color: registroStatus!.contains('éxito') ? Colors.green : Colors.red,
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
