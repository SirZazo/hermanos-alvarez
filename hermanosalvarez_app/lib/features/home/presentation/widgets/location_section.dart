import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import 'google_map_widget.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  static final Uri _mapsUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=Avenida+Pilar+24,+45500+Torrijos,+Toledo',
  );

  static final Uri _phoneUri = Uri.parse('tel:+34925760263');

  static final Uri _emailUri = Uri.parse('mailto:f.alvarez61@hotmail.com');

  Future<void> _openUrl(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              isCompact ? 34 : 58,
              isCompact ? 26 : 28,
              isCompact ? 34 : 58,
              52,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(isCompact: isCompact),

                SizedBox(height: isCompact ? 15 : 18),

                Expanded(
                  child: isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LocationInfo(
                              compact: true,
                              onDirections: () => _openUrl(_mapsUri),
                              onPhone: () => _openUrl(_phoneUri),
                              onEmail: () => _openUrl(_emailUri),
                            ),

                            const SizedBox(height: 16),

                            const Expanded(child: GoogleMapWidget()),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 10,
                              child: _LocationInfo(
                                compact: false,
                                onDirections: () => _openUrl(_mapsUri),
                                onPhone: () => _openUrl(_phoneUri),
                                onEmail: () => _openUrl(_emailUri),
                              ),
                            ),

                            const SizedBox(width: 42),

                            const Expanded(flex: 11, child: _MapArea()),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CABECERA
// -----------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final bool isCompact;

  const _SectionHeader({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DÓNDE ENCONTRARNOS',
          style: TextStyle(
            color: AppColors.heritageGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          width: 38,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.heritageAccent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Estamos en Torrijos',
          style: TextStyle(
            color: AppColors.heritageGreenDark,
            fontSize: isCompact ? 27 : 32,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// INFORMACIÓN DE CONTACTO
// -----------------------------------------------------------------------------

class _LocationInfo extends StatelessWidget {
  final bool compact;

  final VoidCallback onDirections;
  final VoidCallback onPhone;
  final VoidCallback onEmail;

  const _LocationInfo({
    required this.compact,
    required this.onDirections,
    required this.onPhone,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Autocares Hermanos Álvarez',
          style: TextStyle(
            color: AppColors.heritageGreenDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Puedes encontrarnos en nuestras oficinas de Torrijos '
          'para consultar rutas, horarios o solicitar información '
          'sobre nuestros servicios.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: compact ? 12.5 : 13.5,
            height: 1.42,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 16),

        _ContactRow(
          icon: Icons.location_on_outlined,
          title: 'Avenida Pilar, 24',
          subtitle: '45500 Torrijos, Toledo',
          onTap: onDirections,
        ),

        const SizedBox(height: 8),

        _ContactRow(
          icon: Icons.phone_outlined,
          title: '925 760 263',
          onTap: onPhone,
        ),

        const SizedBox(height: 8),

        _ContactRow(
          icon: Icons.mail_outline_rounded,
          title: 'f.alvarez61@hotmail.com',
          onTap: onEmail,
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _PrimaryButton(
              icon: Icons.directions_outlined,
              label: 'Cómo llegar',
              onPressed: onDirections,
            ),

            _SecondaryButton(
              icon: Icons.phone_outlined,
              label: 'Llamar',
              onPressed: onPhone,
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// FILA DE CONTACTO
// -----------------------------------------------------------------------------

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.heritageAccent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.heritageAccent.withValues(alpha: 0.45),
                ),
              ),
              child: Icon(icon, color: AppColors.heritageGreen, size: 19),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.heritageGreenDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 1),

                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MAPA
// -----------------------------------------------------------------------------

class _MapArea extends StatelessWidget {
  const _MapArea();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.94,
        heightFactor: 0.92,
        child: const GoogleMapWidget(),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BOTÓN PRINCIPAL
// -----------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.heritageGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BOTÓN SECUNDARIO
// -----------------------------------------------------------------------------

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.heritageGreenDark,
        backgroundColor: AppColors.heritageBackgroundSoft.withValues(
          alpha: 0.50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        side: BorderSide(
          color: AppColors.heritageGreenSoft.withValues(alpha: 0.55),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
