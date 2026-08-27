import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  static const String _mobileUrl = String.fromEnvironment(
    'TURNSTILE_MOBILE_URL',
    defaultValue:
        'https://www.autocaresalvarezhnos.es/turnstile-mobile.html',
  );

  bool get configurado => _siteKey.isNotEmpty;

  Future<String?> obtenerToken(BuildContext context) async {
    if (!configurado) {
      return null;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      throw const TurnstileException(
        'La verificación anti-bot no está disponible '
        'en esta plataforma.',
      );
    }

    if (!context.mounted) {
      throw const TurnstileException(
        'No se ha podido iniciar la verificación.',
      );
    }

    final uri = Uri.parse(_mobileUrl).replace(
      queryParameters: {
        'sitekey': _siteKey,
      },
    );

    final token = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TurnstileDialog(
        uri: uri,
      ),
    );

    if (token == null || token.trim().isEmpty) {
      throw const TurnstileException(
        'No se ha podido completar la verificación '
        'anti-bot. Inténtalo de nuevo.',
      );
    }

    return token.trim();
  }
}

class _TurnstileDialog extends StatefulWidget {
  final Uri uri;

  const _TurnstileDialog({
    required this.uri,
  });

  @override
  State<_TurnstileDialog> createState() =>
      _TurnstileDialogState();
}

class _TurnstileDialogState extends State<_TurnstileDialog> {
  late final WebViewController _controller;

  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..addJavaScriptChannel(
        'TurnstileChannel',
        onMessageReceived: _procesarMensaje,
      )
      ..loadRequest(widget.uri);
  }

  void _procesarMensaje(
    JavaScriptMessage message,
  ) {
    try {
      final data = jsonDecode(message.message);

      if (data is! Map<String, dynamic>) {
        throw const FormatException();
      }

      final type = data['type']?.toString();
      final value = data['value']?.toString() ?? '';

      if (type == 'token' && value.trim().isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pop(value.trim());
        }

        return;
      }

      if (type == 'error') {
        if (!mounted) {
          return;
        }

        setState(() {
          _error = 'Error Turnstile: $value';
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'No se ha podido completar la verificación.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Verificación de seguridad',
      ),
      content: SizedBox(
        width: 320,
        height: 180,
        child: _error == null
            ? WebViewWidget(
                controller: _controller,
              )
            : Center(
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
