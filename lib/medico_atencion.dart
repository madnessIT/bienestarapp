import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'servicio_provider.dart';
import 'sucursal_provider.dart';

class MedicoAtencionPage extends StatefulWidget {
  const MedicoAtencionPage({super.key});

  @override
  State<MedicoAtencionPage> createState() => _MedicoAtencionPageState();
}

class _MedicoAtencionPageState extends State<MedicoAtencionPage> {
  Map<String, dynamic>? turnoSeleccionado;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String fecha = args?['fecha']?.toString() ?? 'Fecha no disponible';
    final List<dynamic> medicos = args?['medicos'] ?? [];

    // Obtener datos de los proveedores
    final servicioNombre = Provider.of<ServicioProvider>(context).servicioNombre;
    final descripcion = Provider.of<SucursalProvider>(context, listen: false).descripcion;
   // final descripcion = SucursalProvider().descripcion ?? 'Descripción no disponible';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Médicos Disponibles',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo central
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Encabezado con detalles de atención
                    Center(
                      child: Card(
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
                                'Regional: $descripcion',
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
                    ),
                    const SizedBox(height: 10),
                    // Lista de médicos disponibles
                    medicos.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay médicos disponibles',
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: medicos.length,
                            itemBuilder: (context, index) {
                              var medicoData = medicos[index];
                              var medico = medicoData['medico'] ?? {};
                              var persona = medico['persona'] ?? {};
                              var agendaTurnos = medicoData['agenda_turnos'] as List<dynamic>;

                              String descripcionMedico = medicoData['descripcion'] ?? 'Sin descripción';
                              String horaInicio = medicoData['hora_inicio'] ?? 'Hora inicio no disponible';
                              String horaFin = medicoData['hora_fin'] ?? 'Hora fin no disponible';

                              // Nombre completo del doctor
                              String nombreCompleto = '${persona['nombres'] ?? 'Nombre no disponible'} '
                                  '${persona['paterno'] ?? ''} ${persona['materno'] ?? ''}';
                              // ID del doctor
                              int doctorId = medico['id'] is int
                                ? medico['id']
                                : int.tryParse(medico['id']?.toString() ?? '') ?? -1;

                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ExpansionTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Color.fromARGB(255, 1, 179, 45),
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text(
                                    '$nombreCompleto ',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 1, 179, 45),
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Horario: $horaInicio - $horaFin\nDescripción: $descripcionMedico',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Turnos Disponibles:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ...agendaTurnos.map((turno) {
                                        int turnoId = turno['id'] is int
                                          ? turno['id']
                                          : int.tryParse(turno['id']?.toString() ?? '') ?? -1;
                                      String turnoInicio = turno['hora_inicio'] ?? 'Inicio no disponible';
                                      String turnoFin = turno['hora_fin'] ?? 'Fin no disponible';
                                      String turnoFecha = turno['fecha'] ?? 'Fecha no disponible';

                                      bool isSelected = turnoSeleccionado != null &&
                                          turnoSeleccionado!['hora_inicio'] == turnoInicio &&
                                          turnoSeleccionado!['hora_fin'] == turnoFin &&
                                          turnoSeleccionado!['fecha'] == turnoFecha;

                                      return Card(
                                        color: isSelected ? Colors.green[100] : null,
                                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          leading: const Icon(Icons.access_time, color: Color.fromARGB(255, 1, 179, 45)),
                                         // title: Text('Turno ID: $turnoId'),
                                          subtitle: Text('De: $turnoInicio a $turnoFin'),
                                          onTap: () {
                                            setState(() {
                                              turnoSeleccionado = {
                                                'fecha': turnoFecha,
                                                'hora_inicio': turnoInicio,
                                                'hora_fin': turnoFin,
                                                'medico': nombreCompleto,
                                                'doctorId': doctorId,
                                                'id': turnoId,
                                              };
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: turnoSeleccionado != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/prefactura',
                  arguments: turnoSeleccionado,
                );
              },
              label: const Text('Continuar'),
              icon: const Icon(Icons.arrow_forward),
              backgroundColor: const Color.fromARGB(255, 1, 179, 45),
            )
          : null,
    );
  }
}
