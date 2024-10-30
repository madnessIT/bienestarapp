import 'package:flutter/material.dart';

class MisFacturasPage extends StatelessWidget {
  const MisFacturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Facturas'),
      ),
      body: const Center(
        child: Text('Página de Mis Facturas'),
      ),
    );
  }
}
