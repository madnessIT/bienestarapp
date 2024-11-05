import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SucursalAtencionPage extends StatelessWidget {
  const SucursalAtencionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Asignar valores predeterminados en caso de que sean nulos, usando toString() para conversión segura
    final String fecha = args?['fecha']?.toString() ?? '';
    final String departamentoId = args?['departamento_id']?.toString() ?? '';
    final String especialidadId = args?['especialidad_id']?.toString() ?? '';
    final List<dynamic> sucursales = args?['sucursales'] ?? [];

    // Validar que todos los argumentos requeridos estén presentes y no sean vacíos
    if (fecha.isEmpty || departamentoId.isEmpty || especialidadId.isEmpty) {
      print("Error: uno de los parámetros es nulo o vacío.");
      return Scaffold(
        appBar: AppBar(title: const Text('Sucursal Atención')),
        body: const Center(child: Text('Error: Parámetros faltantes o inválidos.')),
      );
    }

    // Función para obtener los médicos usando el campo `codigo`
    Future<void> fetchMedicos(String codigo) async {
      if (codigo.isEmpty) {
        print("Error: código de sucursal es nulo o vacío.");
        return;
      }

      var url = Uri.parse(
        'http://test.api.movil.cies.org.bo/agenda/agendas/turno_by_medico_by_especialidad_and_regional/?regional_id=$codigo&especialidad_id=$especialidadId&fecha=$fecha',
      );

      try {
        var response = await http.get(url);
        if (response.statusCode == 200) {
          var medicos = jsonDecode(response.body);

          // Navega a la página `medico_atencion` pasando los datos de los médicos
          Navigator.pushNamed(
            context,
            '/medico_atencion',
            arguments: {
              'fecha': fecha,
              'departamento_id': departamentoId,
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
        title: const Text('Sucursal Atención'),
      ),
      body: sucursales.isEmpty
          ? const Center(child: Text('No hay sucursales disponibles'))
          : ListView.builder(
              itemCount: sucursales.length,
              itemBuilder: (context, index) {
                var sucursal = sucursales[index];
                var codigo = sucursal['codigo']?.toString() ?? ''; // Convertir `codigo` a String y manejar null

                return ListTile(
                  title: Text(sucursal['nombre']?.toString() ?? 'Sucursal sin nombre'),
                  onTap: () {
                    if (codigo.isNotEmpty) {
                      fetchMedicos(codigo);
                    } else {
                      print("Código de sucursal no disponible.");
                    }
                  },
                );
              },
            ),
    );
  }
}
