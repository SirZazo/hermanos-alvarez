import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_shell.dart';

class LegalPage extends StatelessWidget {
  final String title;
  final String markdown;

  const LegalPage({
    super.key,
    required this.title,
    required this.markdown,
  });

  Future<void> _abrirEnlace(String? href) async {
    if (href == null) return;

    final uri = Uri.parse(href);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Container(
        width: double.infinity,
        color: AppColors.pageBackground,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  42,
                  24,
                  72,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDeep,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 64,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowSoft,
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: MarkdownBody(
                        data: markdown,
                        selectable: true,
                        onTapLink: (
                          text,
                          href,
                          title,
                        ) {
                          _abrirEnlace(href);
                        },
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeep,
                            height: 1.3,
                          ),
                          h2: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            height: 1.35,
                          ),
                          p: const TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: AppColors.textSecondary,
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          a: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          blockSpacing: 18,
                          listBullet: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
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