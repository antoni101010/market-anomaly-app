import 'package:flutter/material.dart';

/// Tema scuro dell'app: pulito, professionale, niente colori sgargianti.
final ThemeData marketAnomalyTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0E1116),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3DDC97),
    secondary: Color(0xFF5B8DEF),
    surface: Color(0xFF161B22),
    error: Color(0xFFE5484D),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF161B22),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
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
    titleLarge: TextStyle(fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontWeight: FontWeight.w600),
  ),
);

/// Colore associato a una fascia di classificazione anomalia.
Color classificationColor(String label) {
  switch (label) {
    case 'SOMIGLIANZA STORICA ALTA':
      return const Color(0xFFE67E22);
    case 'SOMIGLIANZA STORICA MODERATA':
    case 'SOMIGLIANZA STORICA MEDIA':
      return const Color(0xFFF2C94C);
    case 'SOMIGLIANZA STORICA LIMITATA':
      return const Color(0xFF5B8DEF);
    case 'SOMIGLIANZA STORICA BASSA':
      return const Color(0xFF8A93A3);
    case 'ANOMALIA LIGHT MOLTO FORTE':
      return const Color(0xFFE5484D);
    case 'ANOMALIA LIGHT FORTE':
      return const Color(0xFFF2994A);
    case 'ANOMALIA LIGHT MODERATA':
      return const Color(0xFFF2C94C);
    case 'ANOMALIA LIGHT NORMALE':
      return const Color(0xFF5B8DEF);
    case 'RISCHIO STRUTTURALE ELEVATO':
      return const Color(0xFFE5484D);
    case 'ANOMALIA ECCEZIONALE':
    case 'POSSIBILE ANOMALIA FORTE':
    case 'ANOMALIA FORTE DA STUDIARE':
      return const Color(0xFFE5484D);
    case 'ANOMALIA FORTE':
    case 'POSSIBILE ANOMALIA':
      return const Color(0xFFF2994A);
    case 'INTERESSANTE':
    case 'DA APPROFONDIRE':
      return const Color(0xFFF2C94C);
    case 'DA MONITORARE':
      return const Color(0xFF5B8DEF);
    case 'PREZZO DA VERIFICARE':
      return const Color(0xFFFFA726);
    case 'DATI INSUFFICIENTI':
      return const Color(0xFF7E8798);
    case 'NON PRIORITARIA':
    case 'MOVIMENTO NON PRIORITARIO':
    case 'BASSA PRIORITA':
    case 'BASSA PRIORITÀ':
      return const Color(0xFF8A93A3);
    default:
      return const Color(0xFF8A93A3);
  }
}

/// Badge compatto per mostrare uno score (0-100) con colore semantico.
class ScoreBadge extends StatelessWidget {
  final String label;
  final double? value;
  final Color? color;

  const ScoreBadge({super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final v = value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          Text(
            v == null ? '-' : v.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stato vuoto/errore riusabile con azione opzionale.
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
            Icon(icon, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
