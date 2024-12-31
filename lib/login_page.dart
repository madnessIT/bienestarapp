import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expediente_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String? loginStatus;
  bool _isLoading = false;
  bool _pinSent = false;
  bool _showRegisterButton = false;
  String? _pinApp;
  String? _nombre;
  String? _paterno;
  String? _materno;
  String? _ci;

  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/login_codigo_tes/';
  ///afiliacion/cies-contigo/login_codigo_cies_contigo/';

  Future<void> loginPaciente(String documento) async {
    if (documento.isEmpty) {
      setState(() {
        loginStatus = 'Por favor, ingrese su documento de identidad';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      loginStatus = null;
    });

    var url = Uri.parse('$apiUrl?documento=$documento');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');  // Imprimir el cuerpo de la respuesta
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data.containsKey('expedienteclinico') && data['expedienteclinico']['pin_app'] != null) {
          int expedienteId = data['expedienteclinico']['id']; // Obtén el ID del expediente clínico
          Provider.of<ExpedienteProvider>(context, listen: false).setExpedienteclinicoId(expedienteId); // Guarda el ID globalmente
          int expedienteClinico = data['expedienteclinico']['expediente_clinico']; // Obtén el ID del expediente clínico
          Provider.of<ExpedienteProvider>(context, listen: false).setExpedienteClinico(expedienteClinico); // Guarda el ID globalmente
          String? nit = data['nit']; // Obtén el NIT del expediente clínico
          Provider.of<ExpedienteProvider>(context, listen: false).setnit(nit); // Guarda el nit globalmente
          String? razonSocial = data['razon_social']; // Obtén el razon_social del expediente clínico
          Provider.of<ExpedienteProvider>(context, listen: false).setrazonSocial(razonSocial); // Guarda el nit globalmente
          String? documento = data['documento']; // Obtén el ci
          Provider.of<ExpedienteProvider>(context, listen: false).setdocumento(documento); // Guarda documento globalmente

                    
             setState(() {
            _pinApp = data['expedienteclinico']['pin_app'].toString();
            _nombre = data['nombres'];
            _paterno = data['paterno'];
            _materno = data['materno'];
            _ci = data['documento'];
            loginStatus = 'PIN enviado. Por favor ingresa el PIN.';
            _pinSent = true;
            _isLoading = false;
            _showRegisterButton = false;
          });
        } else {
          setState(() {
            loginStatus = 'Error: No se recibió el PIN.';
            _isLoading = false;
            _showRegisterButton = false;
          });
        }
      } else if (response.statusCode == 302) {
        setState(() {
          loginStatus = 'Paciente no encontrado. ¿Deseas registrarte?';
          _isLoading = false;
          _showRegisterButton = true;
        });
      } else {
        setState(() {
          loginStatus = 'Error en el login. Código: ${response.statusCode}';
          _isLoading = false;
          _showRegisterButton = false;
        });
      }
    } catch (e) {
      setState(() {
        loginStatus = 'Error en la conexión';
        _isLoading = false;
        _showRegisterButton = false;
      });
    }
  }

  Future<void> confirmarPin() async {
    String pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() {
        loginStatus = 'Por favor, ingrese su PIN';
      });
      return;
    }

    if (pin == _pinApp) {
      Navigator.pushNamed(
        context,
        '/menu_paciente',
        arguments: {
          'nombre': _nombre,
          'paterno': _paterno,
          'materno': _materno,
          'ci': _ci,
        },
      );
    } else {
      setState(() {
        loginStatus = 'El PIN ingresado es incorrecto';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clinica Bienestar")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _documentoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Documento de Identidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () => loginPaciente(_documentoController.text),
                              child: const Text("Login"),
                            ),
                      if (_pinSent) ...[
                        const SizedBox(height: 20),
                        TextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Ingrese el PIN',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: confirmarPin,
                          child: const Text("Confirmar PIN"),
                        ),
                      ],
                      if (_showRegisterButton) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/register_page'),
                          child: const Text("Registrar Paciente"),
                        ),
                      ],
                    ],
                  ),
                ),
                if (loginStatus != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    loginStatus!,
                    style: TextStyle(
                      color: loginStatus!.contains('éxito') ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
