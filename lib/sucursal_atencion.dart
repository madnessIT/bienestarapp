import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';
import 'servicio_provider.dart';
import 'sucursal_provider.dart';

class SucursalAtencionPage extends StatelessWidget {
  const SucursalAtencionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String fecha = args?['fecha']?.toString() ?? '';
    final String especialidadId = args?['especialidad_id']?.toString() ?? '';
    final List<dynamic> sucursales = args?['sucursales'] ?? [];

    // Obtener datos del FechaProvider
    final fechaProvider = Provider.of<FechaProvider>(context);
    final String departamentoNombre = fechaProvider.departamentoNombre ?? 'Sin nombre';

    // Obtener el nombre del servicio desde el ServicioProvider
    final servicioNombre = Provider.of<ServicioProvider>(context).servicioNombre;

    if (fecha.isEmpty || departamentoNombre.isEmpty || especialidadId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sucursal Atención')),
        body: const Center(child: Text('Error: Parámetros faltantes o inválidos.')),
      );
    }

    Future<void> fetchMedicos(String codigo) async {
      if (codigo.isEmpty) return;

      var url = Uri.parse(
        'http://test.api.movil.cies.org.bo/agenda/agendas/turno_by_medico_by_especialidad_and_regional/?regional_id=$codigo&especialidad_id=$especialidadId&fecha=$fecha',
      );

      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var medicos = jsonDecode(response.body);
          Navigator.pushNamed(
            context,
            '/medico_atencion',
            arguments: {
              'fecha': fecha,
              'especialidad_id': especialidadId,
              'codigo': codigo,
              'medicos': medicos,
            },
          );
        } else {
          print('Error al obtener los médicos: ${response.statusCode}');
        }
      } catch (e) {
        print('Error en la conexión: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sucursales Disponibles',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 1, 179, 45),
                Color.fromARGB(255, 0, 62, 143),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: sucursales.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay sucursales disponibles',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : Column(
                        children: [
                          // Logo
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Encabezado con datos de la atención
                          Card(
                            color: Colors.blue[50],
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fecha Atención: $fecha',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Regional: $departamentoNombre',
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Servicio: $servicioNombre',
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Lista de sucursales
                          Expanded(
                            child: ListView.builder(
                              itemCount: sucursales.length,
                              itemBuilder: (context, index) {
                                var sucursal = sucursales[index];
                                var codigo = sucursal['codigo']?.toString() ?? '';
                                var descripcion = sucursal['descripcion']?.toString() ?? 'Sucursal sin nombre';
                                var direccion = sucursal['direccion']?.toString() ?? 'Dirección no disponible';

                                // Actualizamos el SucursalProvider
                                final sucursalProvider = Provider.of<SucursalProvider>(context, listen: false);
                                sucursalProvider.setSucursal(codigo, descripcion);

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 4,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16.0),
                                    title: Text(
                                      descripcion,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      direccion,
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                                    onTap: () {
                                      if (codigo.isNotEmpty) {
                                        fetchMedicos(codigo);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Código de sucursal no disponible.")),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
