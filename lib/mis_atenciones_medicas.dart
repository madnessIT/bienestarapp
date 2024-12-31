import 'package:flutter/material.dart';

class MisAtencionesMedicasPage extends StatelessWidget {
  const MisAtencionesMedicasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'Solicitud de Atenciones Médicas',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar el logo en la parte superior
            Center(
              child: Image.asset(
                'assets/images/logo.png',  // Ruta de la imagen del logo
                height: 120,  // Altura del logo
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            
            // Tarjetas con las opciones de la pantalla
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
