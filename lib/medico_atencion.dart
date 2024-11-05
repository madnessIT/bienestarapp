import 'package:flutter/material.dart';

class MedicoAtencionPage extends StatelessWidget {
  const MedicoAtencionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final String fecha = args?['fecha']?.toString() ?? 'Fecha no disponible';
    final String departamentoId = args?['departamento_id']?.toString() ?? 'ID de departamento no disponible';
    final String especialidadId = args?['especialidad_id']?.toString() ?? 'ID de especialidad no disponible';
    final String regionalId = args?['codigo']?.toString() ?? 'ID de regional no disponible';
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
              'Departamento ID: $departamentoId\n'
              'Especialidad ID: $especialidadId\n'
              'Regional ID: $regionalId',
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

                      // Obtener los detalles del horario
                      String horaInicio = medicoData['hora_inicio'] ?? 'No disponible';
                      String horaFin = medicoData['hora_fin'] ?? 'No disponible';
                      String descripcion = medicoData['descripcion'] ?? 'Sin descripción';

                      return ListTile(
                        title: Text(
                          '${persona['nombres'] ?? 'Nombre no disponible'} '
                          '${persona['paterno'] ?? ''} '
                          '${persona['materno'] ?? ''}',
                        ),
                        subtitle: Text(
                          'Horario: $horaInicio - $horaFin\nDescripción: $descripcion\n'
                          'Días disponibles: ${_getDiasDisponibles(medicoData)}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Función para obtener los días disponibles del médico
  String _getDiasDisponibles(Map<String, dynamic> medicoData) {
    List<String> dias = [];
    if (medicoData['lunes'] == true) dias.add('Lunes');
    if (medicoData['martes'] == true) dias.add('Martes');
    if (medicoData['miercoles'] == true) dias.add('Miércoles');
    if (medicoData['jueves'] == true) dias.add('Jueves');
    if (medicoData['viernes'] == true) dias.add('Viernes');
    if (medicoData['sabado'] == true) dias.add('Sábado');
    if (medicoData['domingo'] == true) dias.add('Domingo');

    return dias.isNotEmpty ? dias.join(', ') : 'No disponible';
  }
}
