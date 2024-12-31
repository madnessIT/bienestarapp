import 'package:flutter/material.dart';

class MenuPacientePage extends StatelessWidget {
  const MenuPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos pasados desde login_page.dart
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se recibieron los datos del paciente.')),
      );
    }

    // Obtener el nombre y el CI del paciente
    final String? nombre = args['nombre'];
    final String? paterno = args['paterno'];
    final String? materno = args['materno'];
    final String ci = args['ci'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú del Paciente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
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
                    'assets/images/logo.png', // Ruta a tu logo
                    height: 120,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Opciones del menú
                Expanded(
                  child: ListView(
                    children: [
                      _buildMenuOption(
                        context,
                        icon: Icons.local_hospital,
                        title: 'Servicios médicos',
                        color: Colors.blue,
                        routeName: '/mis_atenciones_medicas',
                      ),
                      _buildMenuOption(
                        context,
                        icon: Icons.receipt,
                        title: 'Mis facturas',
                        color: Colors.green,
                        routeName: '/mis_facturas',
                      ),
                      _buildMenuOption(
                        context,
                        icon: Icons.medical_services,
                        title: 'Mis atenciones médicas',
                        color: const Color.fromARGB(255, 1, 179, 45),
                        routeName: '/servicios_medicos',
                      ),
                      _buildMenuOption(
                        context,
                        icon: Icons.contact_phone,
                        title: 'Contáctanos',
                        color: Colors.orangeAccent,
                        routeName: '/contactanos',
                      ),
                    ],
                  ),
                ),
                // Botón para cerrar sesión
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/login')); // Regresar al login
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                    ),
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Barra de navegación en la parte inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Modificar Perfil',
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 1, 179, 45),
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/modify_page'); // Dirigirse a la página de modificación
          }
        },
      ),
      // Mostrar un popup con la imagen de promoción
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPromotionDialog(context);
        },
        child: const Icon(Icons.star),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required String routeName}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }

  // Función para mostrar el pop-up
  void _showPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen de la promoción
              Image.asset(
                'assets/images/promocion.png', // Ruta a tu imagen de promoción
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el pop-up
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
