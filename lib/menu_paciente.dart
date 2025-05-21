import 'package:flutter/material.dart';

class MenuPacientePage extends StatelessWidget {
  const MenuPacientePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos pasados desde login_page.dart
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se recibieron los datos del paciente.')),
      );
    }

    // Obtener el nombre y otros datos del paciente
    final String? nombre = args['nombre'];
    final String? paterno = args['paterno'];
    final String? materno = args['materno'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú del Paciente',
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
                    // Logo en la parte superior
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tarjeta con datos del paciente
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.blueAccent.withOpacity(0.1),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Color.fromARGB(255, 1, 179, 45)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bienvenido: $nombre $paterno $materno',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Opciones del menú
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMenuOption(
                          context,
                          icon: Icons.local_hospital,
                          title: 'Servicios médicos',
                          color: const Color.fromARGB(255, 0, 62, 143),
                          routeName: '/mis_atenciones_medicas',
                        ),
                        _buildMenuOption(
                          context,
                          icon: Icons.receipt,
                          title: 'Mis facturas',
                          color: const Color.fromARGB(255, 1, 179, 45),
                          routeName: '/facturas_page',
                        ),
                        _buildMenuOption(
                          context,
                          icon: Icons.medical_services,
                          title: 'Mis atenciones médicas',
                          color: const Color.fromARGB(255, 0, 62, 143),
                          routeName: '/servicios_medicos',
                        ),
                        _buildMenuOption(
                          context,
                          icon: Icons.contact_phone,
                          title: 'Contáctanos',
                          color: const Color.fromARGB(255, 1, 179, 45),
                          routeName: '/contactanos',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Botón para cerrar sesión
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, ModalRoute.withName('/login'));
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // Barra de navegación inferior
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
            Navigator.pushNamed(context, '/modify_page');
          }
        },
      ),
      // Botón flotante para promociones
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPromotionDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
        child: const Icon(Icons.star),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context,
      {required IconData icon,
      required String title,
      required Color color,
      required String routeName}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }

  void _showPromotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen de promoción con bordes redondeados en la parte superior
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(
                  'assets/images/promocion.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
