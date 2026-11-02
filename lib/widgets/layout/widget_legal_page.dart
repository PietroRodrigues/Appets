import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/legal_section_model.dart';
import 'package:appets/widgets/headers/widget_page_header.dart';
import 'package:appets/widgets/layout/widget_layout.dart';
import 'package:flutter/material.dart';

/// Widget genérico para tela de política ou termos.
class WGLegalPage extends StatelessWidget {
  const WGLegalPage({
    super.key,
    required this.title,
    required this.sections,
    this.showNavHeader = true,
  });

  final String title;
  final List<LegalSectionModel> sections;
  final bool showNavHeader;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return WGScaffold(
      child: Column(
        children: [
          if (showNavHeader)
            WGPageHeader.title(
              title: title,
              showSearchBar: false,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var section in sections) ...[
                    WGSectionTitle(title: section.title),
                    const SizedBox(height: 8),
                    for (var para in section.paragraphs) ...[
                      Text(
                        para,
                        style: ThemeTextStyles.body(colors),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small wrapper for section titles.
class WGSectionTitle extends StatelessWidget {
  const WGSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      title,
      style: ThemeTextStyles.subtitle(colors),
    );
  }
}
