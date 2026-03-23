import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUIÉNES SOMOS',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Una empresa familiar con larga trayectoria',
                        style: textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'En Álvarez Serrano Hermanos trabajamos para ofrecer un servicio de transporte fiable, cómodo y cercano, adaptado a las necesidades de cada viaje.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Tarjeta principal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: isMobile
                      ? Column(
                          children: const [
                            _AboutCopy(),
                            SizedBox(height: 24),
                            _AboutImage(),
                          ],
                        )
                      : const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _AboutCopy(),
                            ),
                            SizedBox(width: 32),
                            Expanded(
                              child: _AboutImage(),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCopy extends StatelessWidget {
  const _AboutCopy();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Somos una empresa de transporte público ubicada en Torrijos, con una trayectoria consolidada y una clara vocación de servicio.',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Contamos con certificación UNE-EN 13816 y licencia comunitaria europea, lo que respalda nuestro compromiso con la calidad y la seguridad.',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Nuestro objetivo es sencillo: que cada cliente viaje con tranquilidad y confianza.',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _AboutImage extends StatelessWidget {
  const _AboutImage();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 340),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/bus1.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 340,
        ),
      ),
    );
  }
}