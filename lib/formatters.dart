import 'package:intl/intl.dart';

String currencySymbol(String currency) {
  final code = currency.trim().toUpperCase();

  switch (code) {
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'GBX':
      return 'p';
    case 'JPY':
      return '¥';
    case 'CNY':
      return '¥';
    case 'HKD':
      return 'HK\$';
    case 'CAD':
      return 'C\$';
    case 'AUD':
      return 'A\$';
    case 'CHF':
      return 'CHF ';
    case 'SEK':
      return 'SEK ';
    case 'NOK':
      return 'NOK ';
    case 'DKK':
      return 'DKK ';
    case 'ZAR':
      return 'R';
    case 'USD':
      return '\$';
    default:
      // Una valuta non riconosciuta non deve mai essere mostrata come USD.
      return code.isEmpty ? '' : '$code ';
  }
}

String formatMoney(double? value, String currency, {int decimals = 2}) {
  if (value == null) return 'n/d';
  return '${currencySymbol(currency)}${value.toStringAsFixed(decimals)}';
}

String formatCompactMoney(double? value, String currency) {
  if (value == null) return 'n/d';
  final symbol = currencySymbol(currency);
  if (value.abs() >= 1000000000) {
    return '$symbol${(value / 1000000000).toStringAsFixed(0)} mld';
  }
  if (value.abs() >= 1000000) {
    return '$symbol${(value / 1000000).toStringAsFixed(0)} mln';
  }
  return '$symbol${value.toStringAsFixed(0)}';
}

String priceStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'live':
      return 'Quota live';
    case 'delayed':
      return 'Quota ritardata';
    case 'last_close':
      return 'Ultima chiusura';
    case 'stale':
      return 'Prezzo non recente';
    case 'conflict':
      return 'Prezzo da verificare';
    default:
      return 'Aggiornamento non verificato';
  }
}

String formatObservedAt(String? value) {
  final parsed = DateTime.tryParse(value ?? '');
  if (parsed == null) return 'orario non disponibile';
  return DateFormat('dd/MM/yyyy HH:mm').format(parsed.toLocal());
}
