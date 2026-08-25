import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';

class SolicitudApiException implements Exception {
  final String message;
  final int? statusCode;

  const SolicitudApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SolicitudesApiService {
  Future<void> enviarSolicitud({
    required String nombre,
    String? empresa,
    required String telefono,
    required String email,
    required String origen,
    required String destino,
    required String fechaIda,
    String? horaIda,
    required bool necesitaVuelta,
    String? fechaVuelta,
    String? horaVuelta,
    required int viajeros,
    String? observaciones,
    required bool aceptaPrivacidad,
    String? turnstileToken,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/solicitudes-discrecionales');

    final body = {
      'nombre': nombre.trim(),
      'empresa': _nullableText(empresa),
      'telefono': telefono.trim(),
      'email': email.trim(),
      'origen': origen.trim(),
      'destino': destino.trim(),
      'fecha_ida': fechaIda,
      'hora_ida': _nullableText(horaIda),
      'tipo_viaje': necesitaVuelta ? 'ida_vuelta' : 'ida',
      'fecha_vuelta': necesitaVuelta ? fechaVuelta : null,
      'hora_vuelta': necesitaVuelta ? _nullableText(horaVuelta) : null,
      'viajeros': viajeros,
      'observaciones': _nullableText(observaciones),
      'acepta_privacidad': aceptaPrivacidad,

      // Token anti-bot de Cloudflare Turnstile.
      'turnstile_token': _nullableText(turnstileToken),

      // Honeypot anti-spam.
      // Nunca se muestra al usuario.
      'website': '',
    };

    http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw const SolicitudApiException(
        'No se ha podido conectar con el servidor. '
        'Comprueba tu conexión e inténtalo de nuevo.',
      );
    }

    if (response.statusCode == 200) {
      return;
    }

    switch (response.statusCode) {
      case 403:
        throw const SolicitudApiException(
          'No hemos podido verificar que la solicitud '
          'sea legítima. Actualiza la página e inténtalo '
          'de nuevo.',
          statusCode: 403,
        );

      case 422:
        throw const SolicitudApiException(
          'Hay datos del formulario que no son válidos. '
          'Revisa los campos e inténtalo de nuevo.',
          statusCode: 422,
        );

      case 429:
        throw const SolicitudApiException(
          'Se han realizado demasiadas solicitudes. '
          'Espera unos minutos antes de volver a intentarlo.',
          statusCode: 429,
        );

      case 503:
        throw const SolicitudApiException(
          'Ahora mismo no hemos podido enviar tu solicitud. '
          'Inténtalo de nuevo dentro de unos minutos.',
          statusCode: 503,
        );

      default:
        throw SolicitudApiException(
          'Se ha producido un error al enviar la solicitud.',
          statusCode: response.statusCode,
        );
    }
  }

  String? _nullableText(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }
}
