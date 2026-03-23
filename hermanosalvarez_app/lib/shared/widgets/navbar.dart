import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../app/router.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(36, 51, 44, 0.05),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const _BrandSection(),
                const SizedBox(width: 24),
                const Expanded(
                  child: Center(
                    child: _MenuSection(),
                  ),
                ),
                const SizedBox(width: 24),
                const _ContactSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 82,
      fit: BoxFit.contain,
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavItem(
          label: 'Inicio',
          isActive: currentRoute == AppRouter.home,
          onTap: () {
            if (currentRoute != AppRouter.home) {
              Navigator.pushReplacementNamed(context, AppRouter.home);
            }
          },
        ),
        _NavItem(
          label: 'Qué ofrecemos',
          onTap: () {},
        ),
        _NavItem(
          label: 'Horarios',
          isActive: currentRoute == AppRouter.horarios,
          onTap: () {
            if (currentRoute != AppRouter.horarios) {
              Navigator.pushReplacementNamed(context, AppRouter.horarios);
            }
          },
        ),
        _NavItem(
          label: 'Contacto',
          onTap: () {},
        ),
      ],
    );
  }
}

//** CONTACT_ITEM BEGIN **/

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        _ContactItem(
          icon: Icons.phone,
          text: '925 760 263',
        ),
        SizedBox(height: 6),
        _ContactItem(
          icon: Icons.email,
          text: 'f.alvarez61@hotmail.com',
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

//** CONTACT NAVITEM BEGIN **/

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor:
              isActive ? AppColors.backgroundSoft : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}