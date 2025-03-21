import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Importación para abrir la URL

import '/expediente_provider.dart';

class PapPage extends StatelessWidget {
  const PapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);
    final expedienteClinico = expedienteProvider.expedienteClinico;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial Papanicolaou',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 1, 179, 45), // Verde
                Color.fromARGB(255, 0, 62, 143), // Azul
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: expedienteClinico == null
          ? const Center(child: Text('No se ha seleccionado ningún expediente clínico.'))
          : FutureBuilder(
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
                    final nombresTipo = item['nombres_tipo'] as List;
                    final id = item['id']; // ID del historial

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Color.fromARGB(255, 1, 179, 45)),
                                const SizedBox(width: 10),
                                Text(
                                  '${item['expediente_clinico']['nombre_paciente']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text('Edad: ${item['expediente_clinico']['edad']}'),
                            const SizedBox(height: 5),
                            Text(
                              'ID Historial: $id', // Muestra el ID del historial
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.local_hospital, color: Color.fromARGB(255, 1, 179, 45)),
                                const SizedBox(width: 10),
                                Text(
                                  'Médico: ${item['comprobante_detalle']['nombre_medico']}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text('Fecha del Resultado: ${_formatDate(item['resultado_fecha'])}'),
                            Text('Detalles: ${item['detalle'] ?? "No especificado"}'),
                            const Divider(),
                            const Text(
                              'Tipos:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            ...nombresTipo.map((tipo) => Text(
                                '- ${tipo['nombre']} (Sección: ${tipo['seccion']})')),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _downloadPdf(id),
                                  icon: const Icon(Icons.download, color: Colors.white),
                                  label: const Text('Descargar PDF'),
                                ),
                              ],
                            ),
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
    final url =
        'http://test.api.movil.cies.org.bo/resultado_pap_informado/list_pap_historial_con_resultado_informados_no_informados/?expediente_clinico=$expedienteClinico';
    final response = await http.get(Uri.parse(url));
    print('Fetching data from: $url');

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


Future<void> _downloadPdf(int id) async {
  final url = Uri.parse(
      'http://test.api.movil.cies.org.bo/examen_complementario/resultado_pap_resultado_editar/$id/resultado_pap_documento/');
  
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir la URL para descargar el PDF.');
  }
}

}
