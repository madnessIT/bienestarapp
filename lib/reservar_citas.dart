import 'package:flutter/material.dart';

class ReservarCitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar y pago de citas médicas'),
      ),
      body: Center(
        child: Text(
          'Aquí puedes reservar citas y hacer el pago',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
