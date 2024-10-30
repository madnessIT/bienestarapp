import 'package:flutter/material.dart';

class ServiciosMedicosPage extends StatelessWidget {
  const ServiciosMedicosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios Médicos'),
      ),
      body: const Center(
        child: Text('Página de Servicios Médicos'),
      ),
    );
  }
}
