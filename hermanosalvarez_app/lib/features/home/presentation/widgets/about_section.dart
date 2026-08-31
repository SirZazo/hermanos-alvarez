import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Fondo completamente transparente.
            const ColoredBox(
              color: Colors.transparent,
            ),

            // Detalle decorativo superior izquierdo.
            if (!isMobile)
              const Positioned(
                left: 28,
                top: 22,
                child: _DecorativeMark(),
              ),

            // Detalle decorativo inferior derecho.
            if (!isMobile)
              Positioned(
                right: 28,
                bottom: 42,
                child: Icon(
                  Icons.eco_outlined,
                  size: 28,
                  color: AppColors.heritageGreen.withValues(
                    alpha: 0.28,
                  ),
                ),
              ),

            isMobile
                ? const _AboutMobile()
                : const _AboutDesktop(),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// DESKTOP
// -----------------------------------------------------------------------------

class _AboutDesktop extends StatelessWidget {
  const _AboutDesktop();

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Dejamos libre la parte inferior para los indicadores.
      padding: const EdgeInsets.fromLTRB(
        54,
        24,
        48,
        50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AboutHeader(),

          const SizedBox(height: 14),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(
                  flex: 10,
                  child: _AboutStoryColumn(),
                ),

                const SizedBox(width: 34),

                const Expanded(
                  flex: 11,
                  child: _ModernBusArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MÓVIL
// -----------------------------------------------------------------------------

class _AboutMobile extends StatelessWidget {
  const _AboutMobile();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        58,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AboutHeader(),

          SizedBox(height: 22),

          _AboutStoryColumn(),

          SizedBox(height: 24),

          SizedBox(
            height: 260,
            child: _ModernBusArea(),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CABECERA
// -----------------------------------------------------------------------------

class _AboutHeader extends StatelessWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: compact ? 0 : 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUIÉNES SOMOS',
                      style: TextStyle(
                        color: AppColors.heritageGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
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
                      'Una empresa familiar con larga trayectoria',
                      style: TextStyle(
                        color: AppColors.heritageGreenDark,
                        fontSize: compact ? 25 : 31,
                        height: 1.04,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (!compact) ...[
              const SizedBox(width: 24),
              const _ExperienceBadge(),
            ],
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// COLUMNA IZQUIERDA
// -----------------------------------------------------------------------------

class _AboutStoryColumn extends StatelessWidget {
  const _AboutStoryColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Generaciones dedicadas al transporte de viajeros, manteniendo '
          'nuestras raíces en Torrijos y una forma de trabajar basada en '
          'la cercanía, la seguridad y la confianza.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            height: 1.42,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 13),

        const _FeatureTimeline(),

        const Spacer(),

        const _HistoricPhotos(),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// LÍNEA DE VALORES
// -----------------------------------------------------------------------------

class _FeatureTimeline extends StatelessWidget {
  const _FeatureTimeline();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 18,
          top: 24,
          bottom: 24,
          child: _TimelineLine(),
        ),

        Column(
          children: [
            _AboutFeature(
              icon: Icons.location_on_outlined,
              title: 'Raíces en Torrijos',
              text: 'Una historia estrechamente ligada a nuestra localidad.',
            ),

            SizedBox(height: 8),

            _AboutFeature(
              icon: Icons.verified_user_outlined,
              title: 'Calidad y seguridad',
              text:
                  'Experiencia, profesionalidad y compromiso en cada servicio.',
            ),

            SizedBox(height: 8),

            _AboutFeature(
              icon: Icons.people_alt_outlined,
              title: 'Trato cercano',
              text:
                  'Una empresa familiar que sigue cuidando cada trayecto.',
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineLine extends StatelessWidget {
  const _TimelineLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.heritageAccent.withValues(alpha: 0.10),
            AppColors.heritageAccent.withValues(alpha: 0.65),
            AppColors.heritageAccent.withValues(alpha: 0.10),
          ],
        ),
      ),
    );
  }
}

class _AboutFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.heritageBackgroundSoft.withValues(
              alpha: 0.72,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.heritageAccent.withValues(
                alpha: 0.62,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.heritageGreen,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.heritageGreenDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11.3,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// FOTOS HISTÓRICAS
// -----------------------------------------------------------------------------

class _HistoricPhotos extends StatelessWidget {
  const _HistoricPhotos();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 138,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -0.018,
              child: const _HistoricPhoto(
                asset: 'assets/images/about_bus_historic_01.png',
              ),
            ),

            const SizedBox(width: 14),

            Transform.rotate(
              angle: 0.018,
              child: const _HistoricPhoto(
                asset: 'assets/images/about_bus_historic_02.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoricPhoto extends StatelessWidget {
  final String asset;

  const _HistoricPhoto({
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 195,
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  16,
                  40,
                  24,
                  0.16,
                ),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              asset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
            ),
          ),
        ),
      ),
    );
  }
}
// -----------------------------------------------------------------------------
// AUTOCAR ACTUAL
// -----------------------------------------------------------------------------

class _ModernBusArea extends StatelessWidget {
  const _ModernBusArea();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.94,
        heightFactor: 0.91,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  16,
                  58,
                  34,
                  0.14,
                ),
                blurRadius: 24,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/about_bus_modern.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          AppColors.heritageGreenDark.withValues(
                            alpha: 0.32,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 18,
                  bottom: 17,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Una historia que sigue en marcha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        width: 42,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.heritageAccent,
                          borderRadius: BorderRadius.circular(999),
                        ),
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

// -----------------------------------------------------------------------------
// MÁS DE 60 AÑOS
// -----------------------------------------------------------------------------

class _ExperienceBadge extends StatelessWidget {
  const _ExperienceBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.heritageGreenDark,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              16,
              58,
              34,
              0.16,
            ),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            color: AppColors.heritageAccent,
            size: 17,
          ),

          SizedBox(width: 9),

          Text(
            'MÁS DE 60 AÑOS A SU SERVICIO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DETALLE DECORATIVO
// -----------------------------------------------------------------------------

class _DecorativeMark extends StatelessWidget {
  const _DecorativeMark();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.filter_vintage_outlined,
      size: 30,
      color: AppColors.heritageGreen.withValues(
        alpha: 0.42,
      ),
    );
  }
}