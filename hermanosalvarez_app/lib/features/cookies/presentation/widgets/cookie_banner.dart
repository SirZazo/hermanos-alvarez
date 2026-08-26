import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/cookie_consent_service.dart';
import 'cookie_settings_dialog.dart';

class CookieBanner extends StatelessWidget {
  const CookieBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CookieConsentService.instance;

    return ValueListenableBuilder<bool?>(
      valueListenable: service.externalServicesAllowed,
      builder: (
        context,
        consent,
        child,
      ) {
        if (consent != null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          minimum: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
              child: Material(
                elevation: 14,
                borderRadius: BorderRadius.circular(18),
                color: AppColors.white,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final compact = constraints.maxWidth < 720;
                      final mobile = constraints.maxWidth < 520;

                      final text = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Tu privacidad',
                            style: TextStyle(
                              color: AppColors.primaryDeep,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Utilizamos almacenamiento estrictamente necesario para recordar tus preferencias. '
                            'Google Maps solo se cargará si autorizas el contenido externo.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      );

                      Widget outlinedAction({
                        required String label,
                        required VoidCallback onPressed,
                      }) {
                        return SizedBox(
                          width: mobile ? double.infinity : null,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 52,
                            ),
                            child: OutlinedButton(
                              onPressed: onPressed,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: Text(label),
                            ),
                          ),
                        );
                      }

                      Widget primaryAction() {
                        return SizedBox(
                          width: mobile ? double.infinity : null,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 52,
                            ),
                            child: ElevatedButton(
                              onPressed: service.acceptAll,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Aceptar'),
                            ),
                          ),
                        );
                      }

                      final buttons = mobile
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                outlinedAction(
                                  label: 'Rechazar',
                                  onPressed: service.rejectAll,
                                ),
                                const SizedBox(height: 10),
                                outlinedAction(
                                  label: 'Configurar',
                                  onPressed: () {
                                    showCookieSettingsDialog(context);
                                  },
                                ),
                                const SizedBox(height: 10),
                                primaryAction(),
                              ],
                            )
                          : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.end,
                              children: [
                                outlinedAction(
                                  label: 'Rechazar',
                                  onPressed: service.rejectAll,
                                ),
                                outlinedAction(
                                  label: 'Configurar',
                                  onPressed: () {
                                    showCookieSettingsDialog(context);
                                  },
                                ),
                                primaryAction(),
                              ],
                            );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            text,
                            const SizedBox(height: 18),
                            buttons,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: text),
                          const SizedBox(width: 28),
                          buttons,
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}