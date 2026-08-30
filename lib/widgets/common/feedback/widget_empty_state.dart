import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/widgets/common/buttons/widget_buttons.dart';

/// Estado vazio reutilizável com ícone, título, descrição e ação opcional.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ÍCONE DESTACADO
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: ThemeColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: ThemeColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            // TÍTULO
            Text(
              title,
              style: ThemeTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),

            // DESCRIÇÃO
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: ThemeTextStyles.body.copyWith(
                  color: ThemeColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // AÇÃO OPCIONAL
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                width: 220,
                height: 46,
                backgroundColor: ThemeColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
