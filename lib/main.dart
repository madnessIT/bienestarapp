import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';
import 'expediente_provider.dart';
import 'servicio_provider.dart';
import 'sucursal_provider.dart';
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
import 'medico_atencion.dart';
import 'modify_page.dart';
import 'mis_reservas.dart';
import 'pap.dart';
import '/servicios_medicos/recetas.dart';
import '/servicios_medicos/signos_vitales.dart';
import '/servicios_medicos/laboratorios.dart';
import '/servicios_medicos/captura_hibrida.dart';
import '/prefactura.dart';

void main()  {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FechaProvider()),
        ChangeNotifierProvider(create: (_) => ExpedienteProvider()),
        ChangeNotifierProvider(create: (_) => ServicioProvider()),
        ChangeNotifierProvider(create: (_) => SucursalProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/servicio_atencion': (context) => const ServiciosAtencionPage(),
        '/medico_atencion': (context) => const MedicoAtencionPage (),
        '/modify_page':(context) => const ModificarPacientePage (),
        '/mis_reservas':(context) =>  const MisReservasPage (),
        '/servicios_medicos/recetas': (context) => const RecetasPage(),
        '/servicios_medicos/signos_vitales': (context) => const SignosVitalesPage(),
        '/servicios_medicos/laboratorios': (context) => const LaboratoriosPage(),
        '/captura_hibrida': (context) => const CapturaHibridaHistorialPage(),
        '/pap': (context) =>  const PapPage(),
        '/prefactura': (context) =>  const PrefacturaPage(),

      },
     
    );
  }
}