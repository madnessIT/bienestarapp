import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'expediente_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _docController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = false;
  bool _pinSent = false;
  bool _showRegister = false;

  String? _backendPin;
  String? _nombre;
  String? _paterno;
  String? _materno;
  String? _ci;

  String? _errorMessage;
  String? _infoMessage;

  final String apiUrl = 'https://api.movil.cies.org.bo/afiliacion/login_codigo_tes/';

  @override
  void dispose() {
    _docController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final documento = _docController.text.trim();

    if (documento.isEmpty || !RegExp(r'^\d+$').hasMatch(documento)) {
      setState(() => _errorMessage = 'Por favor, ingrese un documento válido.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final url = Uri.parse('$apiUrl?documento=$documento');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      final data = jsonDecode(response.body);
      final expedienteProvider = Provider.of<ExpedienteProvider>(context, listen: false);

      if (response.statusCode == 200 &&
          data.containsKey('expedienteclinico') &&
          data['expedienteclinico']['pin_app'] != null) {
        
        expedienteProvider.setPatientId(data['id']);
        expedienteProvider.setExpedienteclinicoId(data['expedienteclinico']['id']);
        expedienteProvider.setExpedienteClinico(data['expedienteclinico']['expediente_clinico']);
        expedienteProvider.setnit(data['nit']);
        expedienteProvider.setrazonSocial(data['razon_social']);
        expedienteProvider.setdocumento(data['documento']);

        setState(() {
          _backendPin = data['expedienteclinico']['pin_app'].toString();
          _nombre = data['nombres'];
          _paterno = data['paterno'];
          _materno = data['materno'];
          _ci = data['documento'];

          _infoMessage = 'PIN enviado. Por favor ingréselo.';
          _pinSent = true;
          _showRegister = false;
        });

      } else if (response.statusCode == 302) {
        setState(() {
          _showRegister = true;
          _errorMessage = 'Paciente no encontrado. ¿Deseas registrarte?';
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmPin() {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Por favor, ingrese su PIN');
      return;
    }

    if (pin == _backendPin) {
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
      setState(() => _errorMessage = 'PIN incorrecto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Image.asset('assets/images/logo.png', height: 120),
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
                          controller: _docController,
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
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("Iniciar Sesión", style: TextStyle(fontSize: 18)),
                              ),
                        const SizedBox(height: 20),
                        if (_infoMessage != null)
                          Text(_infoMessage!, style: const TextStyle(color: Colors.blue)),
                        if (_errorMessage != null)
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
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
                            onPressed: _confirmPin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Confirmar PIN", style: TextStyle(fontSize: 18)),
                          ),
                        ],
                        if (_showRegister) ...[
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register_page');
                            },
                            child: const Text("Registrarse", style: TextStyle(fontSize: 16)),
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
