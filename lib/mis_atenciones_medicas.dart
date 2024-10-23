import 'package:flutter/material.dart';

class MisAtencionesMedicasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud de Atención Médica'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text('Reservar y pago de citas médicas'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Acción para reservar y pago de citas médicas
                  Navigator.pushNamed(context, '/reservar_citas');
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.event_note, color: Colors.green),
                title: const Text('Mis reservas y atenciones'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Acción para ver reservas y atenciones
                  Navigator.pushNamed(context, '/mis_reservas');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
