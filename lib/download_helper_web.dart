// ignore_for_file: deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

void downloadImage(Uint8List imageBytes) {
  final blob = html.Blob([imageBytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = 'qr_code.png';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
