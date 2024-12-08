import 'package:flutter/material.dart';

class ServiciosMedicosPage extends StatelessWidget {
  const ServiciosMedicosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Servicios Médicos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Seleccione un servicio:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long,
                    title: 'Recetas',
                    subtitle: 'Consulta tus recetas médicas.',
                    onTap: () {
                      // Acción para redirigir a Recetas
                      Navigator.pushNamed(context, '/servicios_medicos/recetas');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.monitor_heart,
                    title: 'Última Toma de Signos Vitales',
                    subtitle: 'Revisa la última toma de signos vitales.',
                    onTap: () {
                      // Acción para redirigir a Signos Vitales
                      Navigator.pushNamed(context, '/servicios_medicos/signos_vitales');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.science,
                    title: 'Laboratorios',
                    subtitle: 'Consulta los resultados de tus laboratorios.',
                    onTap: () {
                      // Acción para redirigir a Laboratorios
                      Navigator.pushNamed(context, '/servicios_medicos/laboratorios');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.woman,
                    title: 'Capturas Híbridas',
                    subtitle: 'Consulta los resultados de tus estudios.',
                    onTap: () {
                      // Acción para redirigir a Estudios de PAP
                      Navigator.pushNamed(context, '/captura_hibrida');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.medical_services,
                    title: 'Interconsultas Médicas',
                    subtitle: 'Consulta tus interconsultas médicas.',
                    onTap: () {
                      // Acción para redirigir a Interconsultas Médicas
                      Navigator.pushNamed(context, '/servicios_medicos/interconsultas');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Function() onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 230, 250, 235),
          child: Icon(icon, color: const Color.fromARGB(255, 1, 179, 45)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
