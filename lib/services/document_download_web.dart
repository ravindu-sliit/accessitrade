import 'dart:html' as html;
import 'dart:typed_data';

Future<void> downloadOrderDocument({
  required String fileName,
  required String htmlContent,
}) async {
  final bytes = Uint8List.fromList(htmlContent.codeUnits);
  final blob = html.Blob([bytes], 'application/msword');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
