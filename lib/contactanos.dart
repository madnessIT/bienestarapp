import 'package:flutter/material.dart';

class ContactanosPage extends StatelessWidget {
  const ContactanosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
      ),
      body: const Center(
        child: Text('Contactos'),
      ),
    );
  }
}
