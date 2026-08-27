export 'turnstile_service_stub.dart'
    if (dart.library.io) 'turnstile_service_mobile.dart'
    if (dart.library.js_interop) 'turnstile_service_web.dart';
