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
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController(); // Controlador para el PIN.

  final List<String> _sexoOptions = ['MA', 'FE'];
  //String? _selectedSexo;

  final Map<String, int> _referenciaOptions = {
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

  final Map<String, int> _opcionesEC = {
    'Soltero/a': 1,
    'Casado/a': 2,
    'Viudo/a': 3,
    'Union Libre': 4,
    'Separado/a': 5,
    'Divorciado/a': 6,
    'Concubinado/a': 7
  };
  String? _selectedopcionesEC;

  final Map<String, int> _expedidoOptions = {
    'Santa Cruz': 1,
    'Cochabamba': 2,
    'La Paz': 3,
    'Oruro': 4,
    'Pando': 5,
    'Beni': 6,
    'Chuquisaca': 7,
    'Potosi': 8,
    'Tarija': 9
  };
  String? _selectedexpedido;

  bool _isPinEnabled = false; // Estado para habilitar/deshabilitar la caja de texto del PIN.
  String? registroStatus;

  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/';

  Future<void> registrarPaciente() async {
    var url = Uri.parse(apiUrl);

    Map<String, dynamic> data = {
      "fecha_nacimiento": _fechaNacimientoController.text,
      "nombres": _nombresController.text,
      "paterno": _paternoController.text,
      "materno": _maternoController.text,
      "expedido": _expedidoOptions[_selectedexpedido] ?? 0,
      "domicilio": _domicilioController.text,
      "documento": _documentoController.text,
      "sexo":_sexoOptions ,
      "tipo_documento": "CIN",
      "estadocivil": 1,
      "celular": _celularController.text,
      "asegurado_aux": null,
      "expedienteclinico": {
        "telefono": _celularController.text,
        "email": _emailController.text,
        "referencia": _referenciaOptions[_selectedReferencia] ?? 0,
        "estado_civil": _opcionesEC[_selectedopcionesEC] ?? 0,
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
          _isPinEnabled = true; // Habilitar el campo del PIN.
        });
      } else {
        setState(() {
          registroStatus = 'Error al registrar paciente: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Imprime el error en la consola
    print('Error de conexión: $e');
      setState(() {
        registroStatus = 'Error en la conexión';
      });
    }
  }

  void confirmarPin() {
    // Lógica para confirmar el PIN.
    print('PIN ingresado: ${_pinController.text}');
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
            // Otros campos...
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registrarPaciente,
              child: const Text("Registrar Paciente"),
            ),
            const SizedBox(height: 20),
            if (_isPinEnabled) ...[
              TextField(
                controller: _pinController,
                decoration: const InputDecoration(labelText: 'Ingrese el PIN'),
              ),
              ElevatedButton(
                onPressed: confirmarPin,
                child: const Text("Confirmar PIN"),
              ),
            ],
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
