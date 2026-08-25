class TurnstileException implements Exception {
  final String message;

  const TurnstileException(this.message);

  @override
  String toString() => message;
}

class TurnstileService {
  static const String _siteKey = String.fromEnvironment(
    'TURNSTILE_SITE_KEY',
    defaultValue: '',
  );

  bool get configurado => _siteKey.isNotEmpty;

  Future<String?> obtenerToken() async {
    if (!configurado) {
      return null;
    }

    throw const TurnstileException(
      'La verificación anti-bot no está disponible '
      'en esta plataforma.',
    );
  }
}
