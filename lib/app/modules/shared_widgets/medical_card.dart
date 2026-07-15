import 'package:flutter/material.dart';

class MedicalCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const MedicalCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.iconColor,
    this.onTap,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBgColor =
        backgroundColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;

    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null ||
              icon != null ||
              (actions != null && actions!.isNotEmpty)) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? theme.primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                if (actions != null) ...actions!,
              ],
            ),
            const Divider(height: 24, thickness: 0.8),
          ],
          child,
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: theme.cardTheme.shape is RoundedRectangleBorder
            ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius
            : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withOpacity(0.04)
                : Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: cardContent,
        ),
      ),
    );
  }
}
