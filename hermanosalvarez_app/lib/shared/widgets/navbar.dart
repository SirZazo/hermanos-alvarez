import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../app/router.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return isMobile ? const _MobileNavbar() : const _DesktopNavbar();
  }
}

class _DesktopNavbar extends StatelessWidget {
  const _DesktopNavbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.navInnerBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.10),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10),
                  blurRadius: 22,
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

class _MobileNavbar extends StatelessWidget {
  const _MobileNavbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.navInnerBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.10),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const _BrandSectionMobile(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _MobileContactText(
                      icon: Icons.phone,
                      text: '925 760 263',
                    ),
                    SizedBox(height: 4),
                    _MobileContactText(
                      icon: Icons.email,
                      text: 'Contacto',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.navText,
                      size: 30,
                    ),
                    tooltip: 'Abrir menú',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppNavbarDrawer extends StatelessWidget {
  const AppNavbarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: SafeArea(
        child: Container(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 44,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              _DrawerItem(
                label: 'Inicio',
                isActive: currentRoute == AppRouter.home,
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != AppRouter.home) {
                    Navigator.pushReplacementNamed(context, AppRouter.home);
                  }
                },
              ),
              _DrawerItem(
                label: 'Qué ofrecemos',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _DrawerItem(
                label: 'Horarios',
                isActive: currentRoute == AppRouter.horarios,
                onTap: () {
                  Navigator.pop(context);
                  if (currentRoute != AppRouter.horarios) {
                    Navigator.pushReplacementNamed(context, AppRouter.horarios);
                  }
                },
              ),
              _DrawerItem(
                label: 'Contacto',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _DrawerContactItem(
                  icon: Icons.phone,
                  text: '925 760 263',
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _DrawerContactItem(
                  icon: Icons.email,
                  text: 'f.alvarez61@hotmail.com',
                ),
              ),
            ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color.fromRGBO(215, 227, 219, 0.8),
        ),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: 64,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _BrandSectionMobile extends StatelessWidget {
  const _BrandSectionMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(215, 227, 219, 0.8),
        ),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: 40,
        fit: BoxFit.contain,
      ),
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
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.navText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MobileContactText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MobileContactText({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.accent,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.navText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor:
              isActive ? AppColors.navActiveBackground : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.accent : AppColors.navText,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      tileColor: isActive ? AppColors.backgroundSoft : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _DrawerContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DrawerContactItem({
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}