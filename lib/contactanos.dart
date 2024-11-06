import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactanosPage extends StatelessWidget {
  const ContactanosPage({super.key});

  // Métodos para abrir los enlaces
  void _launchFacebook() async {
    const url = 'https://www.facebook.com/ClinicaBienestarSalud';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace a Facebook';
    }
  }

  void _launchWhatsApp() async {
    const url = 'https://wa.me/59169805848';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace a WhatsApp';
    }
  }

  void _launchWebsite() async {
    const url = 'https://clinicabienestar.tes.com.bo/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace al sitio web';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contáctanos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/logo.png', // Ruta correcta del logo
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Síguenos y contáctanos a través de nuestros canales oficiales:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildContactTile(
                    icon: FontAwesomeIcons.facebook,
                    iconColor: Colors.blue,
                    title: 'Facebook',
                    subtitle: 'Visítanos en Facebook',
                    onTap: _launchFacebook,
                  ),
                  _buildContactTile(
                    icon: FontAwesomeIcons.whatsapp,
                    iconColor: Colors.green,
                    title: 'WhatsApp',
                    subtitle: 'Chatea con nosotros en WhatsApp',
                    onTap: _launchWhatsApp,
                  ),
                  _buildContactTile(
                    icon: FontAwesomeIcons.globe,
                    iconColor: Colors.blueAccent,
                    title: 'Sitio Web',
                    subtitle: 'Visita nuestro sitio web',
                    onTap: _launchWebsite,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para cada enlace
  Widget _buildContactTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: FaIcon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
