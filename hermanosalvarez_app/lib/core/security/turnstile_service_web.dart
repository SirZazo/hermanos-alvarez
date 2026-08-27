import 'dart:js_interop';

import 'package:flutter/material.dart';

@JS('getTurnstileToken')
external JSPromise<JSString> _getTurnstileToken(String siteKey);

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

  Future<String?> obtenerToken(BuildContext context) async {
    if (!configurado) {
      return null;
    }

    try {
      final resultado = await _getTurnstileToken(_siteKey).toDart;

      final token = resultado.toDart.trim();

      if (token.isEmpty) {
        throw const TurnstileException(
          'No se ha podido completar la verificación.',
        );
      }

      return token;
    } catch (_) {
      throw const TurnstileException(
        'No se ha podido completar la verificación '
        'anti-bot. Inténtalo de nuevo.',
      );
    }
  }
}
