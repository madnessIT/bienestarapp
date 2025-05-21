import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expediente_provider.dart';

class FacturasPage extends StatefulWidget {
  @override
  _FacturasPageState createState() => _FacturasPageState();
}

class _FacturasPageState extends State<FacturasPage> {
  Future<List<dynamic>> _fetchFacturas(int patientId) async {
    final url =
        'https://api.movil.cies.org.bo/afiliacion/pacientes/$patientId/facturas/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar las facturas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final expedienteProvider = Provider.of<ExpedienteProvider>(context);
    final patientId = expedienteProvider.PatientId;

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Mis Facturas',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  centerTitle: true,
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
  backgroundColor: Colors.transparent,
  elevation: 0,
),

      body: patientId == null
          ? const Center(child: Text('No se ha definido expediente clínico.'))
          : FutureBuilder<List<dynamic>>(
              future: _fetchFacturas(patientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No se encontraron facturas.'));
                }

                final facturas = snapshot.data!;

                return ListView.builder(
                  itemCount: facturas.length,
                  itemBuilder: (context, index) {
                    final factura = facturas[index];
                    final detalles = factura['detalles'] as List<dynamic>? ?? [];

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 3,
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              'Factura #${factura['numero_comprobante'] ?? 'N/D'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Fecha: ${factura['fecha'] ?? 'Sin fecha'}'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...detalles.map((detalle) {
                                      final referencia = detalle['referencia'];
                                      final profesional = referencia != null
                                          ? '${referencia['nombres'] ?? ''} ${referencia['paterno'] ?? ''} ${referencia['materno'] ?? ''}'.trim()
                                          : 'Sin referencia';

                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(Icons.medical_services_outlined),
                                        title: Text(detalle['descripcion'] ?? 'Sin descripción'),
                                        subtitle: Text(profesional.isNotEmpty
                                            ? profesional
                                            : 'Profesional no identificado'),
                                      );
                                    }).toList(),
                                    const Divider(),
                                    Text.rich(TextSpan(children: [
                                      const TextSpan(
                                          text: 'NIT: ',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: '${factura['nit'] ?? 'No disponible'}'),
                                    ])),
                                    if (factura['cuf'] != null)
                                      Text.rich(TextSpan(children: [
                                        const TextSpan(
                                            text: 'CUF: ',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: '${factura['cuf']}'),
                                      ])),
                                    if (factura['monto_total'] != null)
                                      Text.rich(TextSpan(children: [
                                        const TextSpan(
                                            text: 'Total: ',
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: 'Bs ${factura['monto_total']}'),
                                      ])),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
