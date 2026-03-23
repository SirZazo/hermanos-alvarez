import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 620),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hero_bus.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF001C3A).withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF00142D).withValues(alpha: 0.55),
                    const Color(0xFF00142D).withValues(alpha: 0.25),
                    const Color(0xFF00142D).withValues(alpha: 0.10),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroContent(textTheme: textTheme),
                          const SizedBox(height: 24),
                          const _HeroCard(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 13,
                            child: _HeroContent(textTheme: textTheme),
                          ),
                          const SizedBox(width: 32),
                          const Expanded(
                            flex: 8,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: _HeroCard(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final TextTheme textTheme;

  const _HeroContent({
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSPORTE DE CONFIANZA EN TORRIJOS',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Movemos personas con seguridad, cercanía y experiencia',
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.03,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              'Más de 40 años ofreciendo transporte público y servicios discrecionales con profesionalidad, puntualidad y atención personalizada.',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Solicitar presupuesto'),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Consultar horarios'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 12),
            color: Color.fromRGBO(32, 60, 49, 0.10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compromiso en cada trayecto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          const _HeroPoint(text: 'Más de 40 años de experiencia'),
          const SizedBox(height: 14),
          const _HeroPoint(text: 'Servicio seguro y profesional'),
          const SizedBox(height: 14),
          const _HeroPoint(text: 'Atención cercana y personalizada'),
          const SizedBox(height: 14),
          const _HeroPoint(text: 'Transporte público y discrecional'),
        ],
      ),
    );
  }
}

class _HeroPoint extends StatelessWidget {
  final String text;

  const _HeroPoint({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            '•',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}