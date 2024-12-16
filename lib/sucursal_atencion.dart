import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';

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
          'Sucursal Atención',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
        elevation: 2,
      ),
      body: sucursales.isEmpty
          ? const Center(
              child: Text(
                'No hay sucursales disponibles',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Logo en la parte superior
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png', // Asegúrate de que la ruta sea correcta
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Encabezado con fecha y nombre del departamento
                  Card(
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text(
                        'Fecha de Atención: $fecha',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Regional: $departamentoNombre'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sucursales.length,
                      itemBuilder: (context, index) {
                        var sucursal = sucursales[index];
                        var codigo = sucursal['codigo']?.toString() ?? '';
                        var direccion = sucursal['direccion']?.toString() ?? 'Dirección no disponible';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              sucursal['descripcion']?.toString() ?? 'Sucursal sin nombre',
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
                                print("Código de sucursal no disponible.");
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
    );
  }
}
