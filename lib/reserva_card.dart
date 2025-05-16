import 'package:flutter/material.dart';

class ReservaCard extends StatelessWidget {
  final dynamic atencion;

  const ReservaCard({super.key, required this.atencion});

  @override
  Widget build(BuildContext context) {
    final servicio = atencion['servicio'] ?? {};
    final reserva = atencion['reserva'] ?? {};
    final turno = reserva['turno'] ?? {};

    final medico = servicio['referencia']?['persona'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.calendar_today, 'Fecha: ${turno['fecha'] ?? 'Sin fecha'}'),
            _buildInfoRow(Icons.access_time, 'Hora: ${turno['hora_inicio'] ?? 'Sin hora'}'),
            _buildInfoRow(Icons.attach_money, 'Precio: ${servicio['precio'] ?? 'N/A'} Bs.'),
            _buildInfoRow(Icons.receipt_long, 'Comprobante: ${atencion['comprobante']?['numero_comprobante'] ?? 'N/A'}'),
            _buildInfoRow(
              Icons.person,
              'Médico: ${medico?['nombres'] ?? ''} ${medico?['paterno'] ?? ''} ${medico?['materno'] ?? ''}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
