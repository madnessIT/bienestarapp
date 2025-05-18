import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart'; // Para abrir el archivo

Future<void> downloadImage(Uint8List bytes) async {
  try {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    if (directory == null) throw Exception('Directorio no encontrado');

    final filePath = '${directory.path}/QR_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(filePath).writeAsBytes(bytes);

    // Abrir el archivo para que el usuario elija cómo manejarlo
    await OpenFile.open(filePath); // Requiere el paquete open_file
  } catch (e) {
    throw Exception('Error: $e');
  }
}