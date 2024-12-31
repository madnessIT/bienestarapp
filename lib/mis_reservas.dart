import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expediente_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MisReservasPage extends StatefulWidget {
  const MisReservasPage({super.key});

  @override
  _MisReservasPageState createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  List<dynamic> atenciones = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAtenciones();
  }

  Future<void> fetchAtenciones() async {
    try {
      final expedienteProvider = Provider.of<ExpedienteProvider>(context, listen: false);
      final idExpedienteClinico = expedienteProvider.expedienteclinicoId;
      final url = 'http://test.api.movil.cies.org.bo/historia_clinica/atenciones/$idExpedienteClinico/atenciones_por_paciente';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'regional': '02',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          atenciones = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener las atenciones');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'Mis Reservas',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : atenciones.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes reservas registradas.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: atenciones.length,
                  itemBuilder: (context, index) {
                    final atencion = atenciones[index];
                    final servicio = atencion['servicio'] ?? {};
                    final reserva = atencion['reserva'] ?? {};
                    final turno = reserva['turno'] ?? {};

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.medical_services, color: Colors.teal, size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    servicio['descripcion'] ?? 'Sin descripción',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Fecha: ${turno['fecha'] ?? 'Sin fecha'}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.grey, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Hora: ${turno['hora_inicio'] ?? 'Sin hora'}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.grey, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Precio: ${servicio['precio'] ?? 'N/A'} Bs.',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
