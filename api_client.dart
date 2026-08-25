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

int _priceDecimals(double value, String currency) {
  final code = currency.trim().toUpperCase();
  final magnitude = value.abs();

  // Most Japanese cash equities trade in whole yen. If the provider really
  // returns a fractional price, however, preserve it instead of rounding it
  // away.
  if (code == 'JPY' && magnitude >= 1 && (value - value.round()).abs() < 1e-9) {
    return 0;
  }

  // Preserve the actual quote precision (up to a sensible UI limit). This is
  // important for ASX/TSX/HK/LSE instruments that can legitimately trade in
  // half-cent, mill or fractional-pence increments. Float noise close to a
  // two-decimal quote is ignored.
  final maxDecimals = magnitude >= 1 ? 4 : 6;
  final minDecimals = code == 'JPY' ? 0 : 2;
  for (var decimals = minDecimals; decimals <= maxDecimals; decimals++) {
    final scale = _pow10(decimals);
    final rounded = (value * scale).roundToDouble() / scale;
    final tolerance = 1e-9 * (magnitude < 1 ? 1 : magnitude);
    if ((value - rounded).abs() <= tolerance) return decimals;
  }
  return maxDecimals;
}

double _pow10(int exponent) {
  var value = 1.0;
  for (var i = 0; i < exponent; i++) {
    value *= 10.0;
  }
  return value;
}

String _formattedNumber(double value, int decimals) {
  final pattern = decimals <= 0
      ? '#,##0'
      : '#,##0.${List.filled(decimals, '0').join()}';
  return NumberFormat(pattern, 'en_US').format(value);
}

String formatMoney(double? value, String currency, {int? decimals}) {
  if (value == null || !value.isFinite) return 'n/d';
  final usedDecimals = decimals ?? _priceDecimals(value, currency);
  final symbol = currencySymbol(currency);
  if (currency.trim().toUpperCase() == 'GBX') {
    return '${_formattedNumber(value, usedDecimals)}p';
  }
  return '$symbol${_formattedNumber(value, usedDecimals)}';
}

String formatCompactMoney(double? value, String currency) {
  if (value == null || !value.isFinite) return 'n/d';
  final symbol = currencySymbol(currency);
  final magnitude = value.abs();
  if (magnitude >= 1000000000000) {
    return '$symbol${_formattedNumber(value / 1000000000000, 2)} T';
  }
  if (magnitude >= 1000000000) {
    return '$symbol${_formattedNumber(value / 1000000000, 1)} mld';
  }
  if (magnitude >= 1000000) {
    return '$symbol${_formattedNumber(value / 1000000, 1)} mln';
  }
  return '$symbol${_formattedNumber(value, 0)}';
}

String priceStatusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'live':
      return 'Tempo reale verificato';
    case 'delayed':
      return 'Quota ritardata (~15–20 min)';
    case 'extended_hours':
      return 'Tempo reale · mercato esteso';
    case 'market_closed':
      return 'Mercato chiuso · ultimo trade';
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


String dataSourceLabel(String source) {
  switch (source.trim().toLowerCase()) {
    case 'eodhd_websocket_realtime':
      return 'EODHD · WebSocket realtime USA';
    case 'eodhd_live_or_delayed':
      return 'EODHD · quota recente/ritardata';
    case 'eodhd_bulk_eod':
      return 'EODHD · screening globale EOD';
    case 'historical_close':
    case 'eod_raw_close':
      return 'EODHD · ultima chiusura';
    case 'historical_adjusted_close':
    case 'provider_adjusted_history':
      return 'EODHD · storico rettificato';
    case 'eodhd':
      return 'EODHD';
    case 'unknown':
    case '':
      return 'Fonte non disponibile';
    default:
      return source.replaceAll('_', ' ');
  }
}

String fundamentalsAgeLabel(double? days) {
  if (days == null) return 'Età dato non disponibile';
  if (days < 1) return 'Aggiornati da meno di 1 giorno';
  if (days < 2) return 'Aggiornati da ~1 giorno';
  return 'Aggiornati da ~${days.toStringAsFixed(0)} giorni';
}
