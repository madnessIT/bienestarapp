import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'menu_paciente.dart';

void main() {
  runApp(const AppPacientes());
}

class AppPacientes extends StatelessWidget {
  const AppPacientes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Pacientes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/menu_paciente': (context) => MenuPacientePage(),
      },
      
    );
      
  }

}
