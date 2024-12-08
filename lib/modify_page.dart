import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModifyPage extends StatefulWidget {
  const ModifyPage({super.key});

  @override
  _ModifyPageState createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
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
  bool _isLoading = false;

  // URL del endpoint
  final String apiUrl = 'http://test.api.movil.cies.org.bo/afiliacion/';

  // Método para enviar los datos al servidor
  Future<void> modifyPatient() async {
    setState(() {
      _isLoading = true;
      modifyStatus = null;
    });

    var url = Uri.parse(apiUrl);

    Map<String, dynamic> data = {
      "fecha_nacimiento": _fechaNacimientoController.text,
      "nombres": _nombresController.text,
      "paterno": _paternoController.text,
      "materno": _maternoController.text,
      "expedido": 1, // Ejemplo
      "domicilio": _domicilioController.text,
      "documento": _documentoController.text,
      "sexo": _sexoController.text,
      "tipo_documento": "CIN",
      "estadocivil": 1, // Ejemplo
      "celular": _celularController.text,
      "asegurado_aux": null,
      "expedienteclinico": {
        "telefono": _celularController.text,
        "email": _emailController.text,
        "procedencia_pais": null,
        "procedencia_departamento": null,
        "residencia_pais": null,
        "residencia_departamento": null,
        "residencia_municipio": null,
        "estado_civil": 1, // Ejemplo
        "nivel_instruccion": null,
        "ocupacion": null,
        "idioma_materno": null,
        "idioma_hablado": null,
        "etnia": null,
        "referencia": 1, // Valor por defecto
        "identidad_genero": null,
        "orientacion_sexual": null,
        "regional": 2 // Código de la regional
      }
    };

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'regional': '1', // Código de la sucursal
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          modifyStatus = 'Datos modificados con éxito.';
        });
      } else {
        setState(() {
          modifyStatus = 'Error al modificar datos: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        modifyStatus = 'Error en la conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar Datos del Paciente"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Modifica tus datos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nombresController, "Nombres"),
            _buildTextField(_paternoController, "Apellido Paterno"),
            _buildTextField(_maternoController, "Apellido Materno"),
            _buildTextField(_fechaNacimientoController, "Fecha de Nacimiento (YYYY-MM-DD)"),
            _buildTextField(_domicilioController, "Domicilio"),
            _buildTextField(_documentoController, "Documento de Identidad"),
            _buildTextField(_sexoController, "Sexo (MA/FE)"),
            _buildTextField(_celularController, "Celular"),
            _buildTextField(_emailController, "Correo Electrónico"),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: modifyPatient,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Guardar Cambios"),
                  ),
            const SizedBox(height: 20),
            if (modifyStatus != null)
              Text(
                modifyStatus!,
                style: TextStyle(
                  color: modifyStatus!.contains('éxito') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
