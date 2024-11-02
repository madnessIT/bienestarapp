import 'package:flutter/material.dart';

class SucursalAtencionPage extends StatelessWidget {
  const SucursalAtencionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos pasados desde servicio_atencion.dart
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String fecha = args?['fecha'] ?? 'Fecha no disponible';
    final String departamento = args?['departamento'] ?? 'Departamento no disponible';
    final String especialidad = args?['especialidad'] ?? 'Especialidad no disponible';
    final List<dynamic> sucursales = args?['sucursales'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Sucursal'),
      ),
      body: sucursales.isEmpty
          ? const Center(child: Text('No hay sucursales disponibles'))
          : ListView.builder(
              itemCount: sucursales.length,
              itemBuilder: (context, index) {
                var sucursal = sucursales[index];
                return ListTile(
                  title: Text(sucursal['nombre']),
                  subtitle: Text(sucursal['direccion'] ?? 'Sin dirección'),
                  onTap: () {
                    // Acción al seleccionar una sucursal
                  },
                );
              },
            ),
    );
  }
}
