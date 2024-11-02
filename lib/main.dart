import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'menu_paciente.dart';
import 'servicios_medicos.dart';
import 'mis_facturas.dart';
import 'mis_atenciones_medicas.dart';
import 'contactanos.dart';
import 'reservar_citas.dart';
import 'servicio_atencion.dart';
import 'sucursal_atencion.dart';

void main() {
  runApp(const MyApp());
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
        '/register_page': (context) => const RegisterPage(),
        '/menu_paciente': (context) => const MenuPacientePage(),
        '/servicios_medicos': (context) => const ServiciosMedicosPage(),
        '/mis_facturas': (context) => const MisFacturasPage(),
        '/mis_atenciones_medicas': (context) => const MisAtencionesMedicasPage(),
        '/contactanos': (context) => const ContactanosPage(),
        '/reservar_citas': (context) => const ReservarCitasPage(),
        '/sucursal_atencion': (context) => const SucursalAtencionPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/servicio_atencion') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => ServiciosAtencionPage(
              fecha: args['fecha'],
              departamentoId: args['departamento_id'],
            ),
          );
        }
        return null;
      },
    );
  }
}
