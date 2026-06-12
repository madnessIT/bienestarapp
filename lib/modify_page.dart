import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'expediente_provider.dart';

class ModificarPacientePage extends StatefulWidget {
  const ModificarPacientePage({super.key});

  @override
  _ModificarPacientePageState createState() => _ModificarPacientePageState();
}

class _ModificarPacientePageState extends State<ModificarPacientePage> {
  Map<String, dynamic>? loginData;
  bool isLoading = false;
  bool isSaving = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _domicilioController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nombresController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _domicilioController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> fetchLoginData(documento) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.movil.cies.org.bo/afiliacion/login_codigo_tes/?documento=$documento'),
      );

      if (response.statusCode == 200) {
        setState(() {
          loginData = json.decode(response.body);
          
          _nombresController.text = loginData!['nombres']?.toString() ?? '';
          _paternoController.text = loginData!['paterno']?.toString() ?? '';
          _maternoController.text = loginData!['materno']?.toString() ?? '';
          _domicilioController.text = loginData!['domicilio']?.toString() ?? '';

          if (loginData!['expedienteclinico'] != null) {
            _telefonoController.text = loginData!['expedienteclinico']['telefono']?.toString() ?? '';
            _emailController.text = loginData!['expedienteclinico']['email']?.toString() ?? '';
          }
        });
      } else {
        print('Respuesta del servidor: ${response.body}');
        throw Exception('Error al obtener datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        loginData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _guardarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSaving = true;
    });

    // TODO: Implementar la petición PUT/POST al backend para guardar los datos modificados.
    // Simulamos un retraso
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos guardados correctamente')),
    );
  }

  @override
  void initState() {
    super.initState();
    // Obtener el documento desde el Provider en el contexto
    final documento = Provider.of<ExpedienteProvider>(context, listen: false).documento;
    fetchLoginData(documento);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Mis Datos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 1, 179, 45), Color.fromARGB(255, 0, 62, 143)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loginData != null
              ? Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      _buildTextField(_nombresController, 'Nombres'),
                      const SizedBox(height: 16),
                      _buildTextField(_paternoController, 'Apellido Paterno'),
                      const SizedBox(height: 16),
                      _buildTextField(_maternoController, 'Apellido Materno'),
                      const SizedBox(height: 16),
                      _buildTextField(_domicilioController, 'Domicilio'),
                      const SizedBox(height: 16),
                      _buildTextField(_telefonoController, 'Teléfono', TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildTextField(_emailController, 'Correo Electrónico', TextInputType.emailAddress),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: isSaving ? null : _guardarDatos,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Guardar Cambios', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text('No se pudieron obtener los datos.'),
                ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu $label';
        }
        return null;
      },
    );
  }
}
