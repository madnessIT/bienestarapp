import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveQRImage(Uint8List bytes, BuildContext context) async {
  try {
    // Guardar en directorio temporal de la app (no requiere permisos)
    final tempDir = await getTemporaryDirectory();
    final fileName = 'QR_Bienestar_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Guardar en la galería usando MediaStore (Android 10+)
    const platform = MethodChannel('com.bienestar.app/gallery');
    try {
      await platform.invokeMethod('saveToGallery', {
        'filePath': file.path,
        'fileName': fileName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ QR guardado en tu galería de fotos'),
          backgroundColor: Colors.green,
        ),
      );
    } on PlatformException {
      // Si el canal nativo no está implementado (ej. iOS u otra plataforma/emulador), guardamos en descargas
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final savedFile = File('${downloadsDir.path}/$fileName');
        await savedFile.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ QR guardado en tu carpeta de Descargas'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Último recurso: mostrar diálogo con la ubicación del archivo temporal
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('QR guardado'),
            content: Text('La imagen se guardó en:\n${file.path}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al guardar: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
