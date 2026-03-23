import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CommitmentSection extends StatelessWidget {
  const CommitmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compromiso en cada trayecto',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Más de 40 años de experiencia'),
              SizedBox(height: 10),
              Text('• Servicio seguro y profesional'),
              SizedBox(height: 10),
              Text('• Atención cercana y personalizada'),
              SizedBox(height: 10),
              Text('• Transporte público y discrecional'),
            ],
          ),
        ],
      ),
    );
  }
}