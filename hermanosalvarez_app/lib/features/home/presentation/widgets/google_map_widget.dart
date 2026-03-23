import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class GoogleMapWidget extends StatelessWidget {
  const GoogleMapWidget({super.key});

  static bool _isRegistered = false;
  static const String _viewType = 'google-map-iframe';

  void _registerViewFactory() {
    if (_isRegistered) return;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src =
              'https://www.google.com/maps?q=Avenida%20Pilar%2024%20Torrijos&output=embed'
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;

        return iframe;
      },
    );

    _isRegistered = true;
  }

  @override
  Widget build(BuildContext context) {
    _registerViewFactory();

    return Container(
      height: 340,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const HtmlElementView(viewType: _viewType),
    );
  }
}