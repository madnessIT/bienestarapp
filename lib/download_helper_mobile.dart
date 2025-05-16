import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadImage(Uint8List bytes) async {
  final status = await Permission.storage.request();
  if (status.isGranted) {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final path = '${directory.path}/qr_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(bytes);
      print('Imagen guardada en $path');
    } else {
      print('No se pudo acceder al directorio de almacenamiento externo');
    }
  } else {
    print('Permiso denegado para acceder al almacenamiento');
  }
}
