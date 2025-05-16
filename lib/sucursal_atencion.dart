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

    final fechaProvider = Provider.of<FechaProvider>(context);
    final String departamentoNombre = fechaProvider.departamentoNombre ?? 'Sin nombre';

    final servicioNombre = Provider.of<ServicioProvider>(context).servicioNombre;

    if (fecha.isEmpty || departamentoNombre.isEmpty || especialidadId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sucursal Atención')),
        body: const Center(child: Text('Error: Parámetros faltantes o inválidos.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sucursales Disponibles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Image(
                              image: AssetImage('assets/images/logo.png'),
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
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
                          Expanded(
                            child: ListView.builder(
                              itemCount: sucursales.length,
                              itemBuilder: (context, index) {
                                final sucursal = sucursales[index];
                                final id = sucursal['id']?.toString() ?? '';
                                final codigo = sucursal['codigo']?.toString() ?? '';
                                final descripcion = sucursal['descripcion']?.toString() ?? 'Sucursal sin nombre';
                                final direccion = sucursal['direccion']?.toString() ?? 'Dirección no disponible';

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
                                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                                    onTap: () {
                                      if (codigo.isNotEmpty) {
                                        Provider.of<SucursalProvider>(context, listen: false)
                                            .setSucursal(codigo, descripcion, id);
                                        _fetchMedicos(context, codigo, especialidadId, fecha);
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

  Future<void> _fetchMedicos(
    BuildContext context,
    String codigo,
    String especialidadId,
    String fecha,
  ) async {
    final url = Uri.parse(
      'https://api.movil.cies.org.bo/agenda/agendas/turno_by_medico_by_especialidad_and_regional/?regional_id=$codigo&especialidad_id=$especialidadId&fecha=$fecha',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(url);
      Navigator.of(context).pop(); // Cierra el loader

      if (response.statusCode == 200) {
        final List<dynamic> medicos = jsonDecode(response.body);
        final List<dynamic> medicosInternet = medicos.where((m) => m['internet'] == true).toList();

        Navigator.pushNamed(
          context,
          '/medico_atencion',
          arguments: {
            'fecha': fecha,
            'especialidad_id': especialidadId,
            'codigo': codigo,
            'medicos': medicosInternet,
          },
        );
      } else {
        _showError(context, 'Error al obtener los médicos: ${response.statusCode}');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Cierra el loader si hay error
      _showError(context, 'Error en la conexión: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
