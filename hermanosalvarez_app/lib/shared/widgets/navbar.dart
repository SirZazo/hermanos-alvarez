import 'package:flutter/material.dart';

import '../../app/router.dart';
import '../../core/theme/app_colors.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return isMobile ? const _MobileNavbar() : const _DesktopNavbar();
  }
}

// -----------------------------------------------------------------------------
// DESKTOP
// -----------------------------------------------------------------------------

class _DesktopNavbar extends StatelessWidget {
  const _DesktopNavbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.heritageGreen, AppColors.heritageGreenDark],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.heritageGreenSoft.withValues(alpha: 0.70),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(16, 58, 34, 0.20),
                  blurRadius: 24,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: const Row(
              children: [
                _BrandSection(),

                SizedBox(width: 24),

                Expanded(child: Center(child: _MenuSection())),

                SizedBox(width: 24),

                _ContactSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MÓVIL
// -----------------------------------------------------------------------------

class _MobileNavbar extends StatelessWidget {
  const _MobileNavbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.heritageGreen, AppColors.heritageGreenDark],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.heritageGreenSoft.withValues(alpha: 0.70),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(16, 58, 34, 0.18),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const _BrandSectionMobile(),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MobileContactText(icon: Icons.phone, text: '925 760 263'),
                    SizedBox(height: 4),
                    _MobileContactText(icon: Icons.email, text: 'Contacto'),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
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

// -----------------------------------------------------------------------------
// DRAWER MÓVIL
// -----------------------------------------------------------------------------

class AppNavbarDrawer extends StatelessWidget {
  const AppNavbarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: AppColors.heritageBackgroundSoft,
      child: SafeArea(
        child: Container(
          color: AppColors.heritageBackgroundSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.heritageGreen,
                      AppColors.heritageGreenDark,
                    ],
                  ),
                ),
                child: const Row(
                  children: [_BrandLogo(width: 210, borderRadius: 10)],
                ),
              ),

              const SizedBox(height: 8),

              _DrawerItem(
                label: 'Inicio',
                isActive: currentRoute == AppRouter.home,
                onTap: () {
                  Navigator.pop(context);

                  if (currentRoute != AppRouter.home) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.home,
                      arguments: currentRoute,
                    );
                  }
                },
              ),

              _DrawerItem(
                label: 'Qué ofrecemos',
                isActive: currentRoute == AppRouter.queOfrecemos,
                onTap: () {
                  Navigator.pop(context);

                  if (currentRoute != AppRouter.queOfrecemos) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.queOfrecemos,
                    );
                  }
                },
              ),

              _DrawerItem(
                label: 'Contacto',
                isActive: currentRoute == AppRouter.contacto,
                onTap: () {
                  Navigator.pop(context);

                  if (currentRoute != AppRouter.contacto) {
                    Navigator.pushReplacementNamed(context, AppRouter.contacto);
                  }
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

              const Divider(height: 28, color: AppColors.heritageBorder),

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

// -----------------------------------------------------------------------------
// LOGO
// -----------------------------------------------------------------------------

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return const _BrandLogo(width: 225, borderRadius: 12);
  }
}

class _BrandSectionMobile extends StatelessWidget {
  const _BrandSectionMobile();

  @override
  Widget build(BuildContext context) {
    return const _BrandLogo(width: 145, borderRadius: 9);
  }
}

class _BrandLogo extends StatelessWidget {
  final double width;
  final double borderRadius;

  const _BrandLogo({required this.width, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/images/logo_footer.png',
        width: width,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MENÚ
// -----------------------------------------------------------------------------

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
              Navigator.pushReplacementNamed(
                context,
                AppRouter.home,
                arguments: currentRoute,
              );
            }
          },
        ),

        _NavItem(
          label: 'Qué ofrecemos',
          isActive: currentRoute == AppRouter.queOfrecemos,
          onTap: () {
            if (currentRoute != AppRouter.queOfrecemos) {
              Navigator.pushReplacementNamed(context, AppRouter.queOfrecemos);
            }
          },
        ),

        _NavItem(
          label: 'Contacto',
          isActive: currentRoute == AppRouter.contacto,
          onTap: () {
            if (currentRoute != AppRouter.contacto) {
              Navigator.pushReplacementNamed(context, AppRouter.contacto);
            }
          },
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
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// CONTACTO DESKTOP
// -----------------------------------------------------------------------------

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ContactItem(icon: Icons.phone, text: '925 760 263'),
        SizedBox(height: 6),
        _ContactItem(icon: Icons.email, text: 'f.alvarez61@hotmail.com'),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.heritageAccent),

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

// -----------------------------------------------------------------------------
// CONTACTO MÓVIL
// -----------------------------------------------------------------------------

class _MobileContactText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MobileContactText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.heritageAccent),

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

// -----------------------------------------------------------------------------
// BOTONES DEL NAVBAR
// -----------------------------------------------------------------------------

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
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isActive
              ? const Color.fromRGBO(216, 233, 106, 0.14)
              : Colors.transparent,
          foregroundColor: isActive
              ? AppColors.heritageAccent
              : AppColors.navText,
          overlayColor: const Color.fromRGBO(255, 255, 255, 0.08),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.heritageAccent : AppColors.navText,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ELEMENTOS DEL DRAWER
// -----------------------------------------------------------------------------

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.heritageGreen : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        tileColor: isActive ? AppColors.heritageBackground : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _DrawerContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DrawerContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.heritageGreen),

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
