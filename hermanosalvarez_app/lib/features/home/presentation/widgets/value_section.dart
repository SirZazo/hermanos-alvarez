import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ValueSection extends StatelessWidget {
  const ValueSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 800;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hero_bus.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(12, 57, 110, 0.78),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 70,
                  vertical: isMobile ? 40 : 55,
                ),
                child: isMobile
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ValueSectionContent(isMobile: true),
                          SizedBox(height: 36),
                          _ValueCardsColumn(),
                        ],
                      )
                    : const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: _ValueSectionContent()),
                          SizedBox(width: 80),
                          Expanded(flex: 5, child: _ValueCardsColumn()),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueSectionContent extends StatelessWidget {
  final bool isMobile;

  const _ValueSectionContent({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'NUESTRA FORMA DE TRABAJAR',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 22),

        if (isMobile)
          const Text(
            'Más que transporte,\nuna experiencia de viaje segura',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 34,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          )
        else
          const SizedBox(
            width: 560,
            child: Text(
              'Más que transporte,\nuna experiencia de\nviaje segura',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 38,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

        const SizedBox(height: 26),

        if (isMobile)
          const Text(
            'Cuidamos cada detalle del trayecto para que el viaje sea cómodo, puntual y bien organizado, tanto en transporte regular como en servicios especiales.',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              height: 1.75,
              fontWeight: FontWeight.w400,
            ),
          )
        else
          const SizedBox(
            width: 540,
            child: Text(
              'Cuidamos cada detalle del trayecto para que el viaje sea cómodo, puntual y bien organizado, tanto en transporte regular como en servicios especiales.',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                height: 1.75,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}

class _ValueCardsColumn extends StatelessWidget {
  const _ValueCardsColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ValueCard(
          title: 'Seguridad',
          description:
              'Vehículos cuidados y servicio responsable en cada desplazamiento.',
        ),
        SizedBox(height: 16),
        _ValueCard(
          title: 'Puntualidad',
          description:
              'Planificación eficaz para cumplir con horarios y necesidades reales.',
        ),
        SizedBox(height: 16),
        _ValueCard(
          title: 'Cercanía',
          description:
              'Trato directo, atención personal y compromiso con cada cliente.',
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String title;
  final String description;

  const _ValueCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
