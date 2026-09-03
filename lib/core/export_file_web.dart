import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<bool> saveTextFile(
  String name,
  String text, {
  String mime = 'text/plain',
}) async {
  try {
    final blob = web.Blob(
      <JSAny>[text.toJS].toJS,
      web.BlobPropertyBag(type: mime),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = name
      ..style.display = 'none';
    web.document.body!.appendChild(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (_) {
    return false;
  }
}
