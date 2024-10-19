import 'package:flutter/material.dart';

class MenuPacientePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos pasados desde login_page.dart
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    // Obtener el nombre y el CI del paciente
    final String nombre = args['nombre'];
    final String ci = args['ci'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú del Paciente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el nombre y el CI del paciente
            Text(
              'Bienvenido, $nombre',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'CI: $ci',  // Mostrar el CI del paciente
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí podrías agregar más opciones del menú o acciones
                Navigator.pop(context);  // Regresar al login (si lo deseas)
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
