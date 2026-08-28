{{flutter_js}}
{{flutter_build_config}}

// نحمّل CanvasKit من ملفات التطبيق نفسها بدل CDN غوغل —
// حتى يعمل التطبيق كاملًا دون إنترنت وخلف الشبكات المقيدة.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
