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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 96),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDeep,
            AppColors.primaryDark,
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(216, 233, 106, 0.32),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 42,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 760;

                return Column(
                  children: [
                    if (isCompact)
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FooterBrand(),
                          SizedBox(height: 36),
                          _FooterContactColumn(),
                          SizedBox(height: 36),
                          _FooterLegalColumn(),
                        ],
                      )
                    else
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _FooterBrand(),
                          ),
                          SizedBox(width: 56),
                          Expanded(
                            flex: 4,
                            child: _FooterContactColumn(),
                          ),
                          SizedBox(width: 56),
                          Expanded(
                            flex: 3,
                            child: _FooterLegalColumn(),
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),

                    Container(
                      height: 1,
                      width: double.infinity,
                      color: const Color.fromRGBO(
                        255,
                        255,
                        255,
                        0.12,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const _FooterBottom(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 92,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),

        const SizedBox(height: 20),

        const Text(
          'Autocares Hermanos Álvarez',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Transporte de viajeros con experiencia, cercanía y compromiso.',
          style: TextStyle(
            color: AppColors.navTextSoft,
            fontSize: 14,
            height: 1.6,
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
      children: [
        _FooterTitle(
          text: 'CONTACTA CON NOSOTROS',
        ),

        SizedBox(height: 20),

        _FooterInfoRow(
          icon: Icons.phone_outlined,
          text: '925 760 263',
          url: 'tel:+34925760263',
        ),

        SizedBox(height: 14),

        _FooterInfoRow(
          icon: Icons.email_outlined,
          text: 'f.alvarez61@hotmail.com',
          url: 'mailto:f.alvarez61@hotmail.com',
        ),

        SizedBox(height: 14),

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

class _FooterLegalColumn extends StatelessWidget {
  const _FooterLegalColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FooterTitle(
          text: 'INFORMACIÓN',
        ),

        SizedBox(height: 20),

        _FooterLink(
          text: 'Aviso Legal',
          route: AppRouter.avisoLegal,
        ),

        SizedBox(height: 12),

        _FooterLink(
          text: 'Política de Privacidad',
          route: AppRouter.privacidad,
        ),

        SizedBox(height: 12),

        _FooterLink(
          text: 'Política de Cookies',
          route: AppRouter.cookies,
        ),
      ],
    );
  }
}

class _FooterTitle extends StatelessWidget {
  final String text;

  const _FooterTitle({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 10),

        Text(
          text,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

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
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color.fromRGBO(
                    255,
                    255,
                    255,
                    0.06,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(
                    255,
                    255,
                    255,
                    0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                  ),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: _isHovered
                          ? AppColors.white
                          : AppColors.navTextSoft,
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
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

class _FooterLink extends StatefulWidget {
  final String text;
  final String route;

  const _FooterLink({
    required this.text,
    required this.route,
  });

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
          Navigator.pushNamed(
            context,
            widget.route,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color.fromRGBO(
                    255,
                    255,
                    255,
                    0.06,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: _isHovered
                    ? AppColors.white
                    : AppColors.accent,
              ),

              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _isHovered
                        ? AppColors.white
                        : AppColors.navTextSoft,
                    fontSize: 14,
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
            children: [
              _Copyright(),
              SizedBox(height: 12),
              _FooterCredit(),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              child: _Copyright(),
            ),
            SizedBox(width: 24),
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
        fontSize: 13,
        height: 1.4,
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
        style: TextStyle(
          color: AppColors.navTextSoft,
          fontSize: 13,
        ),
        children: [
          TextSpan(
            text: 'Desarrollado por: ',
          ),
          TextSpan(
            text: 'Álvaro Álvarez Zazo',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}