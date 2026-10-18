{{flutter_js}}
{{flutter_build_config}}

// Keep the renderer with the app instead of depending on Google's CDN.
_flutter.loader.load({config: {canvasKitBaseUrl: 'canvaskit/'}});
