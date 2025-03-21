import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadImage(Uint8List imageBytes) async {
  // Solicita permisos para guardar en almacenamiento
  if (!(await Permission.storage.isGranted)) {
    await Permission.storage.request();
  }
  final result = await ImageGallerySaver.saveImage(imageBytes, quality: 80, name: "qr_code");
  print("Imagen guardada: $result");
}
