import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();  // Controlador para el PIN
  String? loginStatus;
  bool _isLoading = false;
  bool _pinSent = false;  // Bandera para saber si se envió el PIN
  String? _pinApp;  // Aquí guardamos el PIN que se recibe de la API
  String? _nombre;  // Guardamos el nombre del paciente
  String? _paterno;  // Guardamos el nombre del paciente
  String? _ci;  // Guardamos el CI del paciente

  // URL base del endpoint de login
  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/cies-contigo/login_codigo_cies_contigo/';

  // Función para realizar login con el documento de identidad
  Future<void> loginPaciente(String documento) async {
    if (documento.isEmpty) {
      setState(() {
        loginStatus = 'Por favor, ingrese su documento de identidad';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      loginStatus = null; // Limpiar mensajes anteriores
    });

    // Construir la URL con el documento como parámetro
    var url = Uri.parse('$apiUrl?documento=$documento');

    try {
      // Realizar la solicitud POST
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),  // Puedes enviar un cuerpo vacío si no necesitas más datos
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');  // Imprimir el cuerpo de la respuesta

      if (response.statusCode == 200) {
        // Decodificar la respuesta de la API
        var data = jsonDecode(response.body);

        // Verificar si 'pin_app' está en la respuesta
        if (data.containsKey('expedienteclinico') && data['expedienteclinico']['pin_app'] != null) {
          setState(() {
            _pinApp = data['expedienteclinico']['pin_app'].toString();  // Guardar el PIN recibido
            _nombre = data['nombres'];  // Guardar el nombre del paciente
            _paterno = data['paterno'];  // Guardar el primer apellido del paciente
            _ci = data['documento'];  // Guardar el CI del paciente
            loginStatus = 'PIN enviado. Por favor ingresa el PIN.';
            _pinSent = true;  // Habilitar la caja de texto para ingresar el PIN
            _isLoading = false;
          });
        } else {
          setState(() {
            loginStatus = 'Error: No se recibió el PIN.';
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          loginStatus = 'Paciente no encontrado. ¿Deseas registrarte?';
          _isLoading = false;
        });
      } else {
        setState(() {
          loginStatus = 'Error en el login. Código: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loginStatus = 'Error en la conexión';
        _isLoading = false;
      });
    }
  }

  // Función para confirmar el PIN ingresado por el usuario
  Future<void> confirmarPin() async {
    String pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() {
        loginStatus = 'Por favor, ingrese su PIN';
      });
      return;
    }

    // Comparar el PIN introducido con el PIN recibido de la API (pin_app)
    if (pin == _pinApp) {
      // Si el PIN es correcto, redirigir al menú del paciente pasando nombre y CI
      Navigator.pushNamed(
        context,
        '/menu_paciente',
        arguments: {
          'nombre': _nombre,  // Pasar el nombre del paciente
          'paterno': _paterno,  // Pasar el apellido del paciente
          'ci': _ci,          // Pasar el CI del paciente
        },
      );
    } else {
      // Si el PIN es incorrecto, mostrar mensaje de error
      setState(() {
        loginStatus = 'El PIN ingresado es incorrecto';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login de Pacientes"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Añadir el logo de la empresa si es necesario
                Image.asset(
                  'assets/images/logo.png',  // Ruta de tu logo en assets
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
                        offset: const Offset(0, 3), // Cambia la posición de la sombra
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
                              onPressed: () {
                                loginPaciente(_documentoController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text("Login"),
                            ),
                      const SizedBox(height: 20),

                      // Mostrar el campo de PIN solo si se envió el código PIN
                      if (_pinSent) ...[
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
                          onPressed: () {
                            confirmarPin();  // Confirmar el PIN ingresado
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text("Confirmar PIN"),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                loginStatus != null
                    ? Column(
                        children: [
                          Text(
                            loginStatus!,
                            style: TextStyle(
                              color: loginStatus!.contains('exitoso')
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
