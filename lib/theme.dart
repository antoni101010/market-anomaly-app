import 'package:flutter/material.dart';

final ThemeData marketAnomalyTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(
    0xFF0E1116,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3DDC97),
    secondary: Color(0xFF5B8DEF),
    surface: Color(0xFF161B22),
    error: Color(0xFFE5484D),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF161B22),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    margin: const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 0,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0E1116),
    elevation: 0,
    centerTitle: false,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF161B22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
    ),
  ),
);

Color classificationColor(
  String label,
) {
  switch (label) {
    case 'ANOMALIA ECCEZIONALE':
    case 'POSSIBILE ANOMALIA FORTE':
      return const Color(0xFFE5484D);

    case 'ANOMALIA FORTE':
    case 'POSSIBILE ANOMALIA':
      return const Color(0xFFF2994A);

    case 'INTERESSANTE':
    case 'DA APPROFONDIRE':
      return const Color(0xFFF2C94C);

    case 'DA MONITORARE':
      return const Color(0xFF5B8DEF);

    case 'NON PRIORITARIA':
    case 'MOVIMENTO NON PRIORITARIO':
      return const Color(0xFF8A93A3);

    default:
      return const Color(0xFF8A93A3);
  }
}

class ScoreBadge extends StatelessWidget {
  final String label;
  final double? value;
  final Color? color;

  const ScoreBadge({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        color ?? Colors.white;
    final score = value;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 62,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: badgeColor.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            score == null
                ? 'n/d'
                : score.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            if (actionLabel != null &&
                onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
