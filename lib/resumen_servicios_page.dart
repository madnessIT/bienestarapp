import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'servicio_provider.dart';

class ResumenServiciosPage extends StatelessWidget {
  const ResumenServiciosPage({super.key});

  Future<List<Map<String, dynamic>>> fetchPricesForCart(List<Map<String, dynamic>> carrito) async {
    final List<Map<String, dynamic>> cartWithPrices = [];
    for (var item in carrito) {
      final servicioNombre = item['servicioNombre'];
      final regionalCodigo = item['sucursalCodigo'];
      
      final url = 'https://api.movil.cies.org.bo/administracion/servicios/all/?search=$servicioNombre&regional=$regionalCodigo';
      final headers = {"Content-Type": "application/json"};
      
      try {
        final response = await http.get(Uri.parse(url), headers: headers);
        if (response.statusCode == 200) {
          final List<dynamic> result = json.decode(response.body);
          if (result.isNotEmpty) {
            final selectedService = result.first;
            final precio = selectedService['precio'] is Map
                ? selectedService['precio']['precio']
                : selectedService['precio'];
            
            cartWithPrices.add({
              ...item,
              'precioFinal': precio,
              'codigo_backend': selectedService['codigo'],
            });
          } else {
            cartWithPrices.add({...item, 'precioFinal': 0, 'codigo_backend': item['servicioCodigo']});
          }
        } else {
          throw Exception('Error al cargar precio para $servicioNombre');
        }
      } catch (e) {
        cartWithPrices.add({...item, 'precioFinal': 0, 'codigo_backend': item['servicioCodigo']});
      }
    }
    return cartWithPrices;
  }

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
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchPricesForCart(carrito),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Expanded(
                              child: Center(
                                child: Text('Error al cargar precios: ${snapshot.error}'),
                              ),
                            );
                          }

                          final itemsConPrecio = snapshot.data ?? [];

                          return Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: itemsConPrecio.length,
                              itemBuilder: (context, index) {
                                final item = itemsConPrecio[index];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: const Color.fromARGB(255, 1, 179, 45).withValues(alpha: 0.1),
                                          child: const Icon(Icons.medical_services, color: Color.fromARGB(255, 1, 179, 45)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['servicioNombre'] ?? 'Servicio',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(255, 0, 62, 143),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Médico: ${item['medico']}',
                                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                              ),
                                              Text(
                                                'Fecha: ${item['fecha']}',
                                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                              ),
                                              Text(
                                                'Hora: ${item['hora_inicio']} - ${item['hora_fin']}',
                                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                              ),
                                              Text(
                                                'Sucursal: ${item['sucursalDescripcion']}',
                                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromARGB(255, 1, 179, 45).withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      '${item['precioFinal'] ?? 0} BOB',
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(255, 1, 179, 45),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                    onPressed: () {
                                                      servicioProvider.eliminarServicioDelCarrito(index);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
