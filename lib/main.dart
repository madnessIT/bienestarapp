import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'menu_paciente.dart';  // Importa la página del menú del paciente
import 'servicios_medicos.dart';
import 'mis_facturas.dart';
import 'mis_atenciones_medicas.dart';
import 'contactanos.dart';
import 'reservar_citas.dart';
//import 'solicitud_atencion.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Pacientes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register_page': (context) => RegisterPage(),  // Registro Paciente
        '/menu_paciente': (context) => MenuPacientePage(),  // Ruta para el menú del paciente
        //'/solicitud_atencion': (context) => SolicitudAtencionPage(), //Solicitud atencion
        '/servicios_medicos': (context) => ServiciosMedicosPage(),  // Define esta ruta
        '/mis_facturas': (context) => MisFacturasPage(),  // Define esta ruta
        '/mis_atenciones_medicas': (context) => MisAtencionesMedicasPage(),  // Define esta ruta
        '/contactanos': (context) => ContactanosPage(),  // Define esta ruta
        '/reservar_citas': (context) => ReservarCitasPage(),  // Reservar y pagar citas
      },
    );
  }
}
