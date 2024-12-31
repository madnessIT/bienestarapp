import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Para manejar la respuesta JSON
import 'package:http/http.dart' as http; // Para solicitudes HTTP

import 'sucursal_provider.dart';
import 'servicio_provider.dart';
import 'expediente_provider.dart';

class PrefacturaPage extends StatelessWidget {
  const PrefacturaPage({super.key});

  Future<List<dynamic>> fetchServicios(String servicioNombre, String regionalCodigo) async {
    final url =
        'http://test.api.movil.cies.org.bo/administracion/servicios/all/?search=$servicioNombre';

    final headers = {
      'regional': regionalCodigo,
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar los servicios: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? turnoSeleccionado =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final medico = turnoSeleccionado?['medico'] ?? 'No disponible';
    final fecha = turnoSeleccionado?['fecha'] ?? 'No disponible';
    final horaInicio = turnoSeleccionado?['hora_inicio'] ?? 'No disponible';
    final horaFin = turnoSeleccionado?['hora_fin'] ?? 'No disponible';

    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'Datos de la cita',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 1, 179, 45), // Verde        //const Color.fromARGB(255, 1, 179, 45),
          Color.fromARGB(255, 0, 62, 143), // Azul
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),
      body: Consumer3<SucursalProvider, ServicioProvider, ExpedienteProvider>(
        builder: (context, sucursalProvider, servicioProvider, expedienteProvider, child) {
          final nitController = TextEditingController(
            text: expedienteProvider.nit ?? 'No asignado',
          );
          final razonSocialController = TextEditingController(
            text: expedienteProvider.razonSocial ?? 'No asignado',
          );

          return FutureBuilder<List<dynamic>>(
            future: fetchServicios(servicioProvider.servicioNombre, sucursalProvider.codigo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No se encontraron servicios.'));
              } else {
                final servicios = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Turno Seleccionado:'),
                      _buildInfoRow('Fecha:', fecha),
                      _buildInfoRow('Hora:', '$horaInicio - $horaFin'),
                      _buildInfoRow('Médico:', medico),
                      const SizedBox(height: 16),

                      _buildSectionTitle(context, 'Sucursal:'),
                      _buildInfoRow('Descripción:', sucursalProvider.descripcion),
                      const SizedBox(height: 16),

                      _buildSectionTitle(context, 'Servicios Disponibles:'),
                      ...servicios.map((servicio) => _buildServicioCard(servicio)),
                      const SizedBox(height: 16),

                      _buildSectionTitle(context, 'Datos para factura:'),
                      TextField(
                        controller: nitController,
                        decoration: const InputDecoration(
                          labelText: 'NIT',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: razonSocialController,
                        decoration: const InputDecoration(
                          labelText: 'Razón Social',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Lógica para guardar o continuar
                        },
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildServicioCard(Map<String, dynamic> servicio) {
    final precio = servicio['precio'] ?? 'No disponible';
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Servicio: ${servicio['nombre']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Precio: ${precio['precio']} Bs.'),
          ],
        ),
      ),
    );
  }
}
