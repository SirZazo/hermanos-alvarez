import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'google_map_widget.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DÓNDE ENCONTRARNOS',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Visítanos en nuestras oficinas',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),

                // TARJETA BLANCA
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
                          children: [
                            const _LocationInfo(),
                            const SizedBox(height: 24),
                            const GoogleMapWidget(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Expanded(child: _LocationInfo()),
                            SizedBox(width: 32),
                            Expanded(child: GoogleMapWidget()),
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

class _LocationInfo extends StatelessWidget {
  const _LocationInfo();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(  
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Autocares Álvarez Serrano Hermanos',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height:15),
        
        Text(
          'Puedes visitarnos en nuestras oficinas para consultar rutas, horarios o solicitar presupuesto para servicios especiales.',
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        const Text('📍 Avenida Pilar 24'),
        const Text('Torrijos, Toledo'),
        const SizedBox(height: 16),
        const Text('📞 925 760 263'),
        const Text('✉️ f.alvarez61@hotmail.com'),
        const SizedBox(height: 20),
      ],
    );
  }
}