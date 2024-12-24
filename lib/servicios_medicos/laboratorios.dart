import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/expediente_provider.dart';

class LaboratoriosPage extends StatefulWidget {
  const LaboratoriosPage({super.key});

  @override
  _LaboratoriosPageState createState() => _LaboratoriosPageState();
}

class _LaboratoriosPageState extends State<LaboratoriosPage> {
  List<dynamic>? laboratorios;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLaboratorios();
  }

  Future<void> _fetchLaboratorios() async {
    try {
      // Obtener expedienteClinico desde el provider
      final expedienteProvider = Provider.of<ExpedienteProvider>(context, listen: false);
      final expedienteClinico = expedienteProvider.expedienteClinico;

      if (expedienteClinico == null) {
        throw Exception('ID de expediente clínico no disponible.');
      }

      final url = Uri.parse(
          'http://test.api.movil.cies.org.bo/laboratorio/ordenes/$expedienteClinico/paciente/');

      final response = await http.get(
        url,
        headers: {'regional': '02'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        if (decodedData is List<dynamic>) {
          setState(() {
            laboratorios = decodedData;
            _isLoading = false;
          });
        } else {
          throw Exception('Formato de datos inesperado.');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Error de conexión: $e';
      });
      print('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de Laboratorio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Error al cargar los datos de laboratorio.',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                    ],
                  ),
                )
              : laboratorios == null || laboratorios!.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron resultados de laboratorio.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: laboratorios!.length,
                      itemBuilder: (context, index) {
                        final laboratorio = laboratorios![index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orden: ${laboratorio['orden'] ?? 'No disponible'}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Fecha de Creación: ${laboratorio['fecha_creacion'] ?? 'No disponible'}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 12.0),
                                if ((laboratorio['detalles'] ?? []).isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detalles de Exámenes:',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8.0),
                                      ..._buildItems(laboratorio['detalles']),
                                    ],
                                  )
                                else
                                  const Text(
                                    'No hay detalles disponibles.',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  List<Widget> _buildItems(List<dynamic> items) {
    return items.map((item) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Examen: ${item['examen']?['nombre'] ?? 'No disponible'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text('Estado: ${item['estado'] ?? 'No disponible'}'),
          Text('Resultado: ${item['resultado'] ?? 'No disponible'}'),
          const Divider(),
        ],
      );
    }).toList();
  }
}
