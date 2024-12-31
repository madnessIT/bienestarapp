import 'package:flutter/material.dart';

class MisFacturasPage extends StatelessWidget {
  const MisFacturasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Mis Facturas',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 1, 179, 45), // Verde        //const Color.fromARGB(255, 1, 179, 45),
          Color.fromARGB(255, 0, 62, 143), // Azul
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),
      body: const Center(
        child: Text('Página de Mis Facturas'),
      ),
    );
  }
}
