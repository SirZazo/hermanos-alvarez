import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/cookie_consent_service.dart';

Future<void> showCookieSettingsDialog(
  BuildContext context,
) async {
  final service = CookieConsentService.instance;

  bool externalServices =
      service.externalServicesAllowed.value ?? false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Configurar cookies',
              style: TextStyle(
                color: AppColors.primaryDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Puedes decidir qué tecnologías opcionales permites.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const _CookieCategory(
                    title: 'Cookies necesarias',
                    description:
                        'Necesarias para el funcionamiento y para recordar tus preferencias de privacidad.',
                    enabled: true,
                    locked: true,
                  ),

                  const SizedBox(height: 14),

                  _CookieCategory(
                    title: 'Contenido externo',
                    description:
                        'Permite cargar servicios de terceros como Google Maps.',
                    enabled: externalServices,
                    onChanged: (value) {
                      setState(() {
                        externalServices = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(
              24,
              0,
              24,
              20,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await service.setExternalServicesAllowed(
                    externalServices,
                  );

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Guardar preferencias'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _CookieCategory extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  final bool locked;
  final ValueChanged<bool>? onChanged;

  const _CookieCategory({
    required this.title,
    required this.description,
    required this.enabled,
    this.locked = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: enabled,
            onChanged: locked ? null : onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}