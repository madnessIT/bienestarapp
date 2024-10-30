import 'package:flutter/material.dart';

class MenuPacientePage extends StatelessWidget {
  const MenuPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos pasados desde login_page.dart
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Obtener el nombre y el CI del paciente
    final String? nombre = args['nombre'];
    final String? paterno = args ['paterno'];
    final String? materno = args ['materno'];
    final String ci = args['ci'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú del Paciente',
          style: TextStyle(
            color: Colors.white,  // Cambiar el color del texto a blanco
            fontWeight: FontWeight.bold, // Fuente en negrita
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),  // Color de fondo del AppBar
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agregar logo en la parte superior
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',  // Ruta a tu logo
                    height: 120,  // Tamaño del logo
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                // Mostrar el nombre y el CI del paciente
                Text(
                  'Bienvenido, $nombre $paterno $materno',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'CI: $ci',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
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
                            // Redirigir a la página de solicitud de atención médica
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
                          leading: const Icon(Icons.medical_services, color: Color.fromARGB(255, 1, 179, 45)),
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
                      backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                    ),
                    child: const Text('Cerrar sesión', style: TextStyle(
                      fontSize: 16,
                      color: Colors.white)),
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
