import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 96),
      decoration:  BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4B4B4B),
            const Color(0xFF1F1F1F),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),


      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    const Expanded(
                      child: _FooterContactColumn(),
                    ),
                    const SizedBox(width: 32),
                    const Expanded(
                      child: _FooterLegalColumn(),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.10),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        '© 2026 AUTOCARES ÁLVAREZ SERRANO HERMANOS S.L. Todos los derechos reservados',
                        style: TextStyle(
                          color: Color(0xFFD7DDE2),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    _FooterCredit(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterContactColumn extends StatelessWidget {
  const _FooterContactColumn();

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACTA CON NOSOTROS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 18),
        _FooterInfoRow(
          icon: Icons.phone,
          text: '925 760 263',
          color: Color(0xFFFFA500),
        ),
        SizedBox(height: 10),
        _FooterInfoRow(
          icon: Icons.email,
          text: 'f.alvarez61@hotmail.com',
          color: Color(0xFFFFA500),
        ),
        SizedBox(height: 10),
        _FooterInfoRow(
          icon: Icons.near_me,
          text: 'Avenida Pilar, 24 – bajos, 45500, Torrijos, Toledo',
          color: Color(0xFFD7DDE2),
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
        Text(
          'ENLACES LEGALES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 18),
        _FooterLink(text: 'Aviso Legal'),
        SizedBox(height: 10),
        _FooterLink(text: 'Política de Privacidad'),
        SizedBox(height: 10),
        _FooterLink(text: 'Política de Cookies'),
      ],
    );
  }
}

class _FooterInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FooterInfoRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFD7DDE2)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFFA500),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _FooterCredit extends StatelessWidget {
  const _FooterCredit();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFFD7DDE2),
          fontSize: 14,
        ),
        children: [
          TextSpan(text: 'Desarrollado por: '),
          TextSpan(
            text: 'Álvaro Álvarez Zazo',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}