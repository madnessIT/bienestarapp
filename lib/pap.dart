import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expediente_provider.dart';

class PapPage extends StatelessWidget {
  const PapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);
    final expedienteClinico = expedienteProvider.expedienteClinico; // Obteniendo el ID del expediente clínico

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de PAP'),
      ),
      body: FutureBuilder(
        future: _fetchPapHistorial(expedienteClinico),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('No hay datos disponibles.'));
          }

          final papData = snapshot.data as List;
          return ListView.builder(
            itemCount: papData.length,
            itemBuilder: (context, index) {
              final item = papData[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Resultado: ${_formatDate(item['resultado_fecha'])}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Paciente: ${item['expediente_clinico']['nombre_paciente']}'),
                      Text('Edad: ${item['expediente_clinico']['edad']}'),
                      Text('Médico: ${item['comprobante_detalle']['nombre_medico']}'),
                      Text('Detalles: ${item['detalle'] ?? "No especificado"}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List> _fetchPapHistorial(int? expedienteClinico) async {
    final url = 'http://test.api.movil.cies.org.bo/resultado_pap_informado/list_pap_historial_con_resultado_informados_no_informados/?expediente_clinico=$expedienteClinico';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al obtener los datos');
    }
  }

  String _formatDate(String dateTime) {
    return dateTime.split('T')[0];
  }
}
