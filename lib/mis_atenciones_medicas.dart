import 'package:flutter/material.dart';

class MisAtencionesMedicasPage extends StatelessWidget {
  const MisAtencionesMedicasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con fondo degradado
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
                Color.fromARGB(255, 1, 179, 45), // Verde
                Color.fromARGB(255, 0, 62, 143), // Azul
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // Fondo degradado y contenedor centrado para mejorar la responsividad
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
                  children: [
                    // Logo centrado
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Título de sección
                    Text(
                      'Atenciones Médicas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Opción para reservar y pagar citas médicas
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.blue),
                        title: const Text(
                          'Reservar y pago de citas médicas',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/reservar_citas');
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Opción para ver reservas y atenciones previas
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.event_note, color: Colors.green),
                        title: const Text(
                          'Mis reservas y atenciones',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/mis_reservas');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
