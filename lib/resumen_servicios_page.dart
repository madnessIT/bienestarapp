import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'servicio_provider.dart';

class ResumenServiciosPage extends StatelessWidget {
  const ResumenServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resumen de Servicios',
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
              child: Consumer<ServicioProvider>(
                builder: (context, servicioProvider, child) {
                  final carrito = servicioProvider.serviciosCarrito;

                  if (carrito.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No hay servicios seleccionados', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.popUntil(context, ModalRoute.withName('/servicio_atencion'));
                            },
                            child: const Text('Volver a Servicios'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Servicios Seleccionados',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: carrito.length,
                          itemBuilder: (context, index) {
                            final item = carrito[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color.fromARGB(255, 1, 179, 45),
                                  child: Icon(Icons.medical_services, color: Colors.white),
                                ),
                                title: Text(item['servicioNombre'] ?? 'Servicio', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Médico: ${item['medico']}\n'
                                  'Fecha: ${item['fecha']}\n'
                                  'Hora: ${item['hora_inicio']} - ${item['hora_fin']}\n'
                                  'Sucursal: ${item['sucursalDescripcion']}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    servicioProvider.eliminarServicioDelCarrito(index);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                // Volver al principio de la selección de servicio
                                Navigator.popUntil(context, ModalRoute.withName('/servicio_atencion'));
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar otro servicio'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color.fromARGB(255, 1, 179, 45)),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                foregroundColor: const Color.fromARGB(255, 0, 62, 143),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Ir a la prefactura
                                Navigator.pushNamed(context, '/prefactura');
                              },
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Continuar a Prefactura'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
