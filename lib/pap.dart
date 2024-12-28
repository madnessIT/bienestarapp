import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'expediente_provider.dart';

class PapPage extends StatelessWidget {
  const PapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);
    final expedienteClinico = expedienteProvider.expedienteClinico;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de PAP'),
        backgroundColor: Colors.deepPurple,
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
              final nombresTipo = item['nombres_tipo'] as List;

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
                          const Icon(Icons.person, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Text(
                            '${item['expediente_clinico']['nombre_paciente']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text('Edad: ${item['expediente_clinico']['edad']}'),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.local_hospital, color: Colors.deepPurple),
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
                      Text(
                        'Tipos:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      ...nombresTipo.map((tipo) => Text(
                          '- ${tipo['nombre']} (Sección: ${tipo['seccion']})')),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _generatePdf(context, item),
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                          label: const Text('Generar PDF'),
                          style: ElevatedButton.styleFrom(
                            //primary: Colors.deepPurple,
                           // onPrimary: Colors.white,
                          ),
                        ),
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

  Future<void> _generatePdf(BuildContext context, Map item) async {
    final pdf = pw.Document();
    final nombresTipo = item['nombres_tipo'] as List;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Resultado PAP', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
            pw.SizedBox(height: 20),
            pw.Text('Paciente: ${item['expediente_clinico']['nombre_paciente']}'),
            pw.Text('Edad: ${item['expediente_clinico']['edad']}'),
            pw.Text('Médico: ${item['comprobante_detalle']['nombre_medico']}'),
            pw.Text('Fecha del Resultado: ${_formatDate(item['resultado_fecha'])}'),
            pw.Text('Detalles: ${item['detalle'] ?? "No especificado"}'),
            pw.SizedBox(height: 10),
            pw.Text('Tipos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...nombresTipo.map((tipo) => pw.Text('- ${tipo['nombre']} (Sección: ${tipo['seccion']})')),
          ],
        ),
      ),
    );

    // Mostrar el PDF generado
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
