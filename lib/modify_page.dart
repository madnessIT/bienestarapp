import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'expediente_provider.dart';

class ModificarPacientePage extends StatefulWidget {
  @override
  _ModificarPacientePageState createState() => _ModificarPacientePageState();
}

class _ModificarPacientePageState extends State<ModificarPacientePage> {
  Map<String, dynamic>? loginData;
  bool isLoading = false;

  Future<void> fetchLoginData(documento) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://test.api.movil.cies.org.bo/afiliacion/login_codigo_tes/?documento=$documento'),
        //headers: {'Content-Type': 'application/json'},
        //body: json.encode({'documento': documento}),
      );

      if (response.statusCode == 200) {
        setState(() {
          loginData = json.decode(response.body);
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
        title: Text('Datos de Login'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : loginData != null
              ? ListView(
                  padding: EdgeInsets.all(16.0),
                  children: [
                    //Text('ID: ${loginData!['id']}'),
                    Text('Nombres: ${loginData!['nombres']}'),
                    Text('Paterno: ${loginData!['paterno']}'),
                    Text('Materno: ${loginData!['materno']}'),
                    Text('Sexo: ${loginData!['sexo']}'),
                    Text('Fecha de Nacimiento: ${loginData!['fecha_nacimiento']}'),
                    Text('Documento: ${loginData!['documento']}'),
                    Text('Domicilio: ${loginData!['domicilio']}'),
                    Text('NIT: ${loginData!['nit']}'),
                    Text('Razón Social: ${loginData!['razon_social']}'),
                    Text('Tipo Documento: ${loginData!['tipo_documento']}'),
                    Text('Expedido: ${loginData!['expedido']}'),
                    if (loginData!['expedienteclinico'] != null) ...[
                      Text('Expediente Clínico ID: ${loginData!['expedienteclinico']['id']}'),
                      Text('Teléfono: ${loginData!['expedienteclinico']['telefono']}'),
                      Text('Email: ${loginData!['expedienteclinico']['email']}'),
                      Text('Procedencia País: ${loginData!['expedienteclinico']['procedencia_pais']}'),
                      Text('Residencia Departamento: ${loginData!['expedienteclinico']['residencia_departamento']}'),
                      Text('Referencia: ${loginData!['expedienteclinico']['referencia']}'),
                      Text('PIN App: ${loginData!['expedienteclinico']['pin_app']}'),
                    ],
                    if (loginData!['asegurado'] != null) ...[
                      Text('Asegurado ID: ${loginData!['asegurado']['id']}'),
                      Text('Seguro: ${loginData!['asegurado']['seguro']}'),
                      Text('Tipo de Asegurado: ${loginData!['asegurado']['tipo_asegurado']}'),
                      Text('Código de Asegurado: ${loginData!['asegurado']['codigo_asegurado']}'),
                      Text('Fecha de Afiliación: ${loginData!['asegurado']['fecha_afiliacion']}'),
                    ],
                  ],
                )
              : Center(
                  child: Text('No se pudieron obtener los datos.'),
                ),
    );
  }
}
