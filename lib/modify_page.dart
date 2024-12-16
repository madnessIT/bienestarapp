import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '/expediente_provider.dart';

class ModificarPacientePage extends StatefulWidget {
  const ModificarPacientePage({super.key});

  @override
  _ModificarPacientePageState createState() => _ModificarPacientePageState();
}

class _ModificarPacientePageState extends State<ModificarPacientePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "nombres": "",
    "paterno": "",
    "materno": "",
    "sexo": "",
    "fecha_nacimiento": "",
    "documento": "",
    "expedido": "",
    "domicilio": "",
    "celular": "",
    "email": "",
    "estado_civil": "",
    "procedencia_pais": "",
    "procedencia_departamento": "",
    "residencia_pais": "",
    "residencia_departamento": "",
    "residencia_municipio": "",
    "ocupacion": "",
    "referencia": "",
    "identidad_genero": ""
  };

  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  // Cargar datos del paciente
  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final expedienteClinicoId = Provider.of<ExpedienteProvider>(context, listen: false).expedienteclinicoId;
    
    if (expedienteClinicoId == null) {
      setState(() {
        _statusMessage = "Expediente clínico no encontrado.";
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://test.api.movil.cies.org.bo/afiliacion/pacientes/$expedienteClinicoId/');
    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');  // Para ver el contenido completo

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _formData['nombres'] = data['nombres'] ?? '';
          _formData['paterno'] = data['paterno'] ?? '';
          _formData['materno'] = data['materno'] ?? '';
          _formData['sexo'] = data['sexo'] ?? '';
          _formData['fecha_nacimiento'] = data['fecha_nacimiento'] ?? '';
          _formData['documento'] = data['documento'] ?? '';
          _formData['expedido'] = data['expedido'] ?? '';
          _formData['domicilio'] = data['domicilio'] ?? '';
          _formData['celular'] = data['expedienteclinico']['telefono'] ?? '';
          _formData['email'] = data['expedienteclinico']['email'] ?? '';
          _formData['estado_civil'] = data['expedienteclinico']['estado_civil'] ?? '';
          _formData['procedencia_pais'] = data['expedienteclinico']['procedencia_pais'] ?? '';
          _formData['procedencia_departamento'] = data['expedienteclinico']['procedencia_departamento'] ?? '';
          _formData['residencia_pais'] = data['expedienteclinico']['residencia_pais'] ?? '';
          _formData['residencia_departamento'] = data['expedienteclinico']['residencia_departamento'] ?? '';
          _formData['residencia_municipio'] = data['expedienteclinico']['residencia_municipio'] ?? '';
          _formData['ocupacion'] = data['expedienteclinico']['ocupacion'] ?? '';
          _formData['referencia'] = data['expedienteclinico']['referencia'] ?? '';
          _formData['identidad_genero'] = data['expedienteclinico']['identidad_genero'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = "Error al cargar los datos del paciente.";
          _isLoading = false;
        });
      }
    } 
    
    catch (e) {
      setState(() {
        _statusMessage = "Error en la conexión: $e";
        _isLoading = false;
      });
    }
  }

  // Actualizar los datos del paciente
  Future<void> _updatePaciente(int expedienteClinicoId) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final url = Uri.parse('http://test.api.movil.cies.org.bo/afiliacion/pacientes/$expedienteClinicoId/');
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          ..._formData,
          "expedienteclinico": {
            "regional": _formData["expedido"],
            "telefono": _formData["celular"],
            "email": _formData["email"],
            "estado_civil": _formData["estado_civil"],
            "procedencia_pais": _formData["procedencia_pais"],
            "procedencia_departamento": _formData["procedencia_departamento"],
            "residencia_pais": _formData["residencia_pais"],
            "residencia_departamento": _formData["residencia_departamento"],
            "residencia_municipio": _formData["residencia_municipio"],
            "ocupacion": _formData["ocupacion"],
            "referencia": _formData["referencia"],
            "identidad_genero": _formData["identidad_genero"],
          },
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "Datos actualizados exitosamente.";
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = "Error al actualizar datos. Código: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error de conexión: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expedienteClinicoId = Provider.of<ExpedienteProvider>(context).expedienteclinicoId;

    if (expedienteClinicoId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Modificar Paciente")),
        body: const Center(
          child: Text("Error: expediente clínico no encontrado."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar Paciente"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ..._buildFormFields(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _updatePaciente(expedienteClinicoId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Actualizar Datos", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                    if (_statusMessage != null)
                      Text(
                        _statusMessage!,
                        style: TextStyle(
                          color: _statusMessage!.contains("exitosamente") ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildTextField("Nombres", "nombres"),
      _buildTextField("Apellido Paterno", "paterno"),
      _buildTextField("Apellido Materno", "materno"),
      _buildTextField("Sexo (M/F)", "sexo"),
      _buildTextField("Fecha de Nacimiento (YYYY-MM-DD)", "fecha_nacimiento"),
      _buildTextField("Documento de Identidad", "documento"),
      _buildTextField("Expedido", "expedido"),
      _buildTextField("Domicilio", "domicilio"),
      _buildTextField("Celular", "celular"),
      _buildTextField("Email", "email"),
      _buildTextField("Estado Civil", "estado_civil"),
      _buildTextField("País de Procedencia", "procedencia_pais"),
      _buildTextField("Departamento de Procedencia", "procedencia_departamento"),
      _buildTextField("País de Residencia", "residencia_pais"),
      _buildTextField("Departamento de Residencia", "residencia_departamento"),
      _buildTextField("Municipio de Residencia", "residencia_municipio"),
      _buildTextField("Ocupación", "ocupacion"),
      _buildTextField("Referencia", "referencia"),
      _buildTextField("Identidad de Género", "identidad_genero"),
    ];
  }

  Widget _buildTextField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        initialValue: _formData[key],
        onSaved: (value) {
          _formData[key] = value;
        },
      ),
    );
  }
}
