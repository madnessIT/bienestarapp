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
  final TextEditingController _expedidoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _sexoOptions = ['MA', 'FE'];
  String? _selectedSexo;

  final Map<String, int> _referenciaOptions = <String, int>{
    'Servicios Medicos': 1,
    'Educadores': 2,
    'Profesores Lideres': 3,
    'Lideres Juveniles': 4,
    'Convenios': 6,
    'Medios de Comunicacion': 7,
    'Publicidad de Calle': 8,
    'Ferias': 9,
    'Redes Sociales': 10,
    'Otros Servicios de Salud': 11,
    'Migracion': 12,
    'Otro Usuario': 5,
  };
  String? _selectedReferencia;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  String? registroStatus;

  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/';

  Future<void> registrarPaciente() async {
    var url = Uri.parse(apiUrl);

    Map<String, dynamic> data = {
      "fecha_nacimiento": _fechaNacimientoController.text,
      "nombres": _nombresController.text,
      "paterno": _paternoController.text,
      "materno": _maternoController.text,
      "expedido": 1, // Ejemplo
      "domicilio": _domicilioController.text,
      "documento": _documentoController.text,
      "sexo": _selectedSexo ?? "MA",
      "tipo_documento": "CIN",
      "estadocivil": 1,
      "celular": _celularController.text,
      "asegurado_aux": null,
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
        "idioma_materno": 1,
        "idioma_hablado": 1,
        "etnia": 1,
        "referencia": _referenciaOptions[_selectedReferencia] ?? 0,
        "identidad_genero": 1,
        "orientacion_sexual": null,
        "regional": 2
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
  title: const Text(
    'Registro del Paciente',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 1, 179, 45), // Verde        //const Color.fromARGB(255, 1, 179, 45),
          Color.fromARGB(255, 0, 62, 143), // Azul
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
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
              readOnly: true,
              onTap: () => _selectDate(context),
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
              controller: _expedidoController,
              decoration: const InputDecoration(labelText: 'Expedido en'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedSexo,
              decoration: const InputDecoration(labelText: 'Sexo MA / FE'),
              items: _sexoOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSexo = newValue;
                });
              },
            ),
            TextField(
              controller: _celularController,
              decoration: const InputDecoration(labelText: 'Celular'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedReferencia,
              decoration: const InputDecoration(labelText: '¿Cómo conoció BIENESTAR?'),
              items: _referenciaOptions.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedReferencia = newValue;
                });
              },
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
