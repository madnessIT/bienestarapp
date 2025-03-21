import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QRResponsePage extends StatelessWidget {
  final Map<String, dynamic> qrResponse;

  const QRResponsePage({super.key, required this.qrResponse});

  @override
  Widget build(BuildContext context) {
    // Codificador JSON con indentación para formato legible
    final String prettyJson = const JsonEncoder.withIndent('  ').convert(qrResponse);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Respuesta QR"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: qrResponse.isEmpty
            ? const Center(
                child: Text(
                  'No se encontró información',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                child: SelectableText(
                  prettyJson,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Courier', // Fuente monoespaciada para mejor legibilidad
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Copiar al portapapeles',
        child: const Icon(Icons.copy),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: prettyJson));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contenido copiado al portapapeles')),
          );
        },
      ),
    );
  }
}
