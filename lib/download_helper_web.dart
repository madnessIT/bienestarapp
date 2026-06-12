import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<void> saveQRImage(Uint8List bytes, BuildContext context) async {
  try {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", "QR_Bienestar_${DateTime.now().millisecondsSinceEpoch}.png")
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ QR descargado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al descargar: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
