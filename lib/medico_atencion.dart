import 'package:flutter/material.dart';

class MedicoAtencionPage extends StatelessWidget {
  const MedicoAtencionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String fecha = args?['fecha']?.toString() ?? 'Fecha no disponible';
   // final String departamentoId = args?['departamento_id']?.toString() ?? 'ID de departamento no disponible';
    final String especialidadId = args?['especialidad_id']?.toString() ?? 'ID de especialidad no disponible';
    final String regionalId = args?['codigo']?.toString() ?? 'ID de regional no disponible';
    //final String nombre = args?['nombre']?.toString() ?? 'nombre de especialidad no disponible';
    final List<dynamic> medicos = args?['medicos'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Médicos Disponibles'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Fecha: $fecha\n'
              //'Departamento ID: $departamentoId\n'
              'Especialidad ID: $especialidadId\n'
              //'Nombre: $nombre\n'
              'Regional ID: $regionalId\n',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: medicos.isEmpty
                ? const Center(child: Text('No hay médicos disponibles'))
                : ListView.builder(
                    itemCount: medicos.length,
                    itemBuilder: (context, index) {
                      var medicoData = medicos[index];
                      var medico = medicoData['medico'] ?? {};
                      var persona = medico['persona'] ?? {};
                      var agendaTurnos = medicoData['agenda_turnos'] as List<dynamic>;

                      // Detalles del horario y médico
                      String descripcion = medicoData['descripcion'] ?? 'Sin descripción';
                      String horaInicio = medicoData['hora_inicio'] ?? 'Hora inicio no disponible';
                      String horaFin = medicoData['hora_fin'] ?? 'Hora fin no disponible';
                      String nombreCompleto = '${persona['nombres'] ?? 'Nombre no disponible'} '
                          '${persona['paterno'] ?? ''} ${persona['materno'] ?? ''}';

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ExpansionTile(
                          title: Text(nombreCompleto),
                          subtitle: Text('Horario: $horaInicio - $horaFin\nDescripción: $descripcion'),
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Turnos Disponibles:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...agendaTurnos.map((turno) {
                              String turnoInicio = turno['hora_inicio'] ?? 'Inicio no disponible';
                              String turnoFin = turno['hora_fin'] ?? 'Fin no disponible';
                              String turnoFecha = turno['fecha'] ?? 'Fecha no disponible';

                              return ListTile(
                                title: Text('Fecha: $turnoFecha'),
                                subtitle: Text('De: $turnoInicio a $turnoFin'),
                                onTap: () {
                                  // Maneja la selección del turno aquí
                                  print("Turno seleccionado: $turnoInicio - $turnoFin");
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
