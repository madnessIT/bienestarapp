import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Para manejar la respuesta JSON
import 'package:http/http.dart' as http; // Para solicitudes HTTP

import 'sucursal_provider.dart';
import 'servicio_provider.dart';
import 'expediente_provider.dart';

class PrefacturaPage extends StatelessWidget {
  const PrefacturaPage({super.key});

  // Método para obtener los servicios desde el endpoint con encabezados
  Future<List<dynamic>> fetchServicios(String servicioNombre, String regionalCodigo) async {
    final url =
        'http://test.api.movil.cies.org.bo/administracion/servicios/all/?search=$servicioNombre';

    final headers = {
      'regional': regionalCodigo, // Agregar el encabezado con el código regional
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data; // Se espera que el endpoint retorne una lista de servicios
    } else {
      throw Exception('Error al cargar los servicios: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener los datos enviados desde MedicoAtencionPage
    final Map<String, dynamic>? turnoSeleccionado =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Datos del turno seleccionado
    final medico = turnoSeleccionado?['medico'] ?? 'No disponible';
    final fecha = turnoSeleccionado?['fecha'] ?? 'No disponible';
    final horaInicio = turnoSeleccionado?['hora_inicio'] ?? 'No disponible';
    final horaFin = turnoSeleccionado?['hora_fin'] ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prefactura'),
      ),
      body: Consumer3<SucursalProvider, ServicioProvider, ExpedienteProvider>(
        builder: (context, sucursalProvider, servicioProvider, expedienteProvider, child) {
          return FutureBuilder<List<dynamic>>(
            future: fetchServicios(servicioProvider.servicioNombre, sucursalProvider.codigo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No se encontraron servicios.'));
              } else {
                final servicios = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mostrar datos del turno seleccionado
                      Text(
                        'Turno Seleccionado:',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text('Fecha: $fecha'),
                      Text('Hora: $horaInicio - $horaFin'),
                      Text('Médico: $medico'),
                      const SizedBox(height: 16),

                      // Mostrar datos de la sucursal
                      Text(
                        'Sucursal:',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text('Código: ${sucursalProvider.codigo}'),
                      Text('Descripción: ${sucursalProvider.descripcion}'),
                      const SizedBox(height: 16),

                      // Mostrar los servicios obtenidos del endpoint
                      Text(
                        'Servicios Disponibles:',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      ...servicios.map((servicio) {
                        final precio = servicio['precio'] ?? 'No disponible';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Servicio: ${servicio['nombre']}'),
                            Text('Precio: ${precio['precio']} Bs.'),
                            const Divider(), // Separador entre servicios
                          ],
                        );
                      }).toList(),

                      const SizedBox(height: 16),

                      // Mostrar los datos del expediente clínico
                      Text(
                        'Expediente Clínico:',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text('NIT: ${expedienteProvider.nit ?? 'No asignado'}'),
                      Text(
                          'Razón Social: ${expedienteProvider.razonSocial ?? 'No asignado'}'),
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
}
