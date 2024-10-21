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
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          // Fondo con color
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar el nombre y el CI del paciente
                Text(
                  'Bienvenido, $nombre',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'CI: $ci',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),

                // Opciones del menú
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.local_hospital, color: Colors.blue),
                          title: const Text('Servicios médicos'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Acción para Servicios Médicos
                            Navigator.pushNamed(context, '/servicios_medicos');
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
                          leading: const Icon(Icons.receipt, color: Colors.green),
                          title: const Text('Mis facturas'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Acción para Mis Facturas
                            Navigator.pushNamed(context, '/mis_facturas');
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
                          leading: const Icon(Icons.medical_services, color: Colors.redAccent),
                          title: const Text('Mis atenciones médicas'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Acción para Mis Atenciones Médicas
                            Navigator.pushNamed(context, '/mis_atenciones_medicas');
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
                          leading: const Icon(Icons.contact_phone, color: Colors.orangeAccent),
                          title: const Text('Contáctanos'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Acción para Contactarnos
                            Navigator.pushNamed(context, '/contactanos');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón para cerrar sesión
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);  // Regresar al login
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color.fromARGB(255, 63, 150, 51),
                    ),
                    child: const Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
