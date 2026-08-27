import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _environmentUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String _productionUrl =
      'https://hermanos-alvarez-api.vercel.app';

  static String get baseUrl {
    // Si proporcionamos una URL mediante --dart-define,
    // utilizamos esa (producción, preview, desarrollo local, etc.)
    if (_environmentUrl.isNotEmpty) {
      return _environmentUrl;
    }

    // Flutter Web en desarrollo local.
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Aplicaciones móviles utilizan por defecto la API pública.
    return _productionUrl;
  }
}
