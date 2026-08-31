import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';

Future<void> _abrirUrl(String url) async {
  final uri = Uri.parse(url);

  if (!await launchUrl(uri)) {
    throw Exception('No se pudo abrir $url');
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        return Column(
          children: [
            // -----------------------------------------------------------------
            // CAJA PRINCIPAL CENTRADA
            // -----------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 22 : 30,
                      vertical: isCompact ? 24 : 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.heritageGreen,
                          AppColors.heritageGreenDark,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.heritageGreenSoft.withValues(
                          alpha: 0.72,
                        ),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(16, 58, 34, 0.18),
                          blurRadius: 24,
                          offset: Offset(0, 9),
                        ),
                      ],
                    ),
                    child: isCompact
                        ? const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FooterBrand(),

                              SizedBox(height: 24),

                              _FooterDividerHorizontal(),

                              SizedBox(height: 20),

                              _FooterContactColumn(),

                              SizedBox(height: 24),

                              _FooterDividerHorizontal(),

                              SizedBox(height: 20),

                              _FooterLegalColumn(),
                            ],
                          )
                        : const IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 4, child: _FooterBrand()),

                                SizedBox(width: 26),

                                _FooterDividerVertical(),

                                SizedBox(width: 26),

                                Expanded(
                                  flex: 4,
                                  child: _FooterContactColumn(),
                                ),

                                SizedBox(width: 26),

                                _FooterDividerVertical(),

                                SizedBox(width: 26),

                                Expanded(flex: 3, child: _FooterLegalColumn()),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2),

            // -----------------------------------------------------------------
            // BARRA INFERIOR FULL WIDTH
            // -----------------------------------------------------------------
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.heritageGreenDark,
                border: Border(
                  top: BorderSide(color: AppColors.heritageAccent, width: 1),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 20 : 26,
                      vertical: isCompact ? 10 : 8,
                    ),
                    child: const _FooterBottom(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// MARCA
// -----------------------------------------------------------------------------

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo compacto, manteniendo exactamente la proporción 400 x 108.
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: AspectRatio(
              aspectRatio: 400 / 108,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/logo_footer.png',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Autocares Hermanos Álvarez',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 280),
          child: Text(
            'Transporte de viajeros con experiencia, '
            'cercanía y compromiso.',
            style: TextStyle(
              color: AppColors.navTextSoft,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterContactColumn extends StatelessWidget {
  const _FooterContactColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FooterTitle(text: 'CONTACTA CON NOSOTROS'),

        SizedBox(height: 12),

        _FooterInfoRow(
          icon: Icons.phone_outlined,
          text: '925 760 263',
          url: 'tel:+34925760263',
        ),

        SizedBox(height: 5),

        _FooterInfoRow(
          icon: Icons.email_outlined,
          text: 'f.alvarez61@hotmail.com',
          url: 'mailto:f.alvarez61@hotmail.com',
        ),

        SizedBox(height: 5),

        _FooterInfoRow(
          icon: Icons.location_on_outlined,
          text: 'Avenida Pilar, 24 – bajos\n45500 Torrijos, Toledo',
          url:
              'https://www.google.com/maps/search/?api=1&query=Avenida+Pilar+24+45500+Torrijos+Toledo',
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// INFORMACIÓN LEGAL
// -----------------------------------------------------------------------------

class _FooterLegalColumn extends StatelessWidget {
  const _FooterLegalColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _FooterTitle(text: 'INFORMACIÓN'),

        SizedBox(height: 12),

        _FooterLink(text: 'Aviso Legal', route: AppRouter.avisoLegal),

        SizedBox(height: 5),

        _FooterLink(
          text: 'Política de Privacidad',
          route: AppRouter.privacidad,
        ),

        SizedBox(height: 5),

        _FooterLink(text: 'Política de Cookies', route: AppRouter.cookies),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// TÍTULOS
// -----------------------------------------------------------------------------

class _FooterTitle extends StatelessWidget {
  final String text;

  const _FooterTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.heritageAccent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),

        const SizedBox(width: 9),

        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// CONTACTO INTERACTIVO
// -----------------------------------------------------------------------------

class _FooterInfoRow extends StatefulWidget {
  final IconData icon;
  final String text;
  final String url;

  const _FooterInfoRow({
    required this.icon,
    required this.text,
    required this.url,
  });

  @override
  State<_FooterInfoRow> createState() => _FooterInfoRowState();
}

class _FooterInfoRowState extends State<_FooterInfoRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () => _abrirUrl(widget.url),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.heritageAccent.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.heritageAccent.withValues(alpha: 0.20),
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 16,
                  color: AppColors.heritageAccent,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _isHovered ? AppColors.white : AppColors.navTextSoft,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
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
// ENLACES
// -----------------------------------------------------------------------------

class _FooterLink extends StatefulWidget {
  final String text;
  final String route;

  const _FooterLink({required this.text, required this.route});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, widget.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: _isHovered ? AppColors.white : AppColors.heritageAccent,
              ),

              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _isHovered ? AppColors.white : AppColors.navTextSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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
// SEPARADORES
// -----------------------------------------------------------------------------

class _FooterDividerVertical extends StatelessWidget {
  const _FooterDividerVertical();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: AppColors.heritageAccent.withValues(alpha: 0.38),
    );
  }
}

class _FooterDividerHorizontal extends StatelessWidget {
  const _FooterDividerHorizontal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: AppColors.heritageAccent.withValues(alpha: 0.28),
    );
  }
}

// -----------------------------------------------------------------------------
// BARRA INFERIOR
// -----------------------------------------------------------------------------

class _FooterBottom extends StatelessWidget {
  const _FooterBottom();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;

        if (isCompact) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_Copyright(), SizedBox(height: 7), _FooterCredit()],
          );
        }

        return const Row(
          children: [
            Expanded(child: _Copyright()),
            SizedBox(width: 20),
            _FooterCredit(),
          ],
        );
      },
    );
  }
}

class _Copyright extends StatelessWidget {
  const _Copyright();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '© 2026 AUTOCARES ÁLVAREZ SERRANO HERMANOS S.L. '
      'Todos los derechos reservados',
      style: TextStyle(
        color: AppColors.navTextSoft,
        fontSize: 11.5,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _FooterCredit extends StatelessWidget {
  const _FooterCredit();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        style: TextStyle(color: AppColors.navTextSoft, fontSize: 11.5),
        children: [
          TextSpan(text: 'Desarrollado por: '),
          TextSpan(
            text: 'Álvaro Álvarez Zazo',
            style: TextStyle(
              color: AppColors.heritageAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
