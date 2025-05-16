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

final String apiUrl = 'https://api.movil.cies.org.bo/afiliacion/login_codigo_tes/';
//final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/login_codigo_tes/';
  Future<void> loginPaciente(String documento) async {
    if (documento.isEmpty || !RegExp(r'^[0-9]+').hasMatch(documento)) {
      setState(() {
        loginStatus = 'Por favor, ingrese un documento de identidad válido';
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

      var data = jsonDecode(response.body);
      final expedienteProvider = Provider.of<ExpedienteProvider>(context, listen: false);
      print("Respuesta de la API: ${response.body}");
      if (response.statusCode == 200 &&
          data.containsKey('expedienteclinico') &&
          data['expedienteclinico']['pin_app'] != null) {
        // Almacenar datos en el provider
        expedienteProvider.setPatientId(data['id']);
        expedienteProvider.setExpedienteclinicoId(data['expedienteclinico']['id']);
        expedienteProvider.setExpedienteClinico(data['expedienteclinico']['expediente_clinico']);
        expedienteProvider.setnit(data['nit']);
        expedienteProvider.setrazonSocial(data['razon_social']);
        expedienteProvider.setdocumento(data['documento']);

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
        loginStatus = 'Error en la conexión: ${e.toString()}';
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
      // Fondo degradado para la web
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
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
                            prefixIcon: const Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                onPressed: () => loginPaciente(_documentoController.text),
                                child: const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                        if (loginStatus != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            loginStatus!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (_pinSent) ...[
                          const SizedBox(height: 20),
                          TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Ingrese el PIN',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: const Size.fromHeight(50),
                            ),
                            onPressed: confirmarPin,
                            child: const Text(
                              "Confirmar PIN",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        if (_showRegisterButton) ...[
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register_page');
                            },
                            child: const Text(
                              "Registrarse",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
