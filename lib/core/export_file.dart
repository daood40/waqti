// حفظ نص كملف: على الويب يُنزَّل مباشرة، وعلى بقية المنصات
// يعود `false` ليتولى المستدعي النسخ إلى الحافظة.
export 'export_file_stub.dart'
    if (dart.library.js_interop) 'export_file_web.dart';
