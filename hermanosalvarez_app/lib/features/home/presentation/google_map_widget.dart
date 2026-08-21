import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:hermanosalvarez_app/features/cookies/data/cookie_consent_service.dart';

import '../../../../core/theme/app_colors.dart';

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
    final consentService = CookieConsentService.instance;

    return ValueListenableBuilder<bool?>(
      valueListenable: consentService.externalServicesAllowed,
      builder: (
        context,
        externalServicesAllowed,
        child,
      ) {
        if (externalServicesAllowed != true) {
          return _BlockedGoogleMap(
            onAllow: () async {
              await consentService.setExternalServicesAllowed(true);
            },
          );
        }

        // IMPORTANTE:
        // El iframe de Google solo se registra cuando ya existe consentimiento.
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
          child: const HtmlElementView(
            viewType: _viewType,
          ),
        );
      },
    );
  }
}

class _BlockedGoogleMap extends StatelessWidget {
  final Future<void> Function() onAllow;

  const _BlockedGoogleMap({
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Google Maps está bloqueado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryDeep,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Para mostrar el mapa necesitamos cargar contenido proporcionado '
                'por Google. Puedes permitirlo únicamente para esta categoría.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              ElevatedButton.icon(
                onPressed: () async {
                  await onAllow();
                },
                icon: const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                ),
                label: const Text(
                  'Permitir Google Maps',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}