import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _environmentUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    // Si proporcionamos una URL mediante --dart-define,
    // utilizamos esa (producción, preview, etc.)
    if (_environmentUrl.isNotEmpty) {
      return _environmentUrl;
    }

    // Flutter Web en desarrollo local
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Android / dispositivo de desarrollo
    return 'http://192.168.1.39:8000';
  }
}
