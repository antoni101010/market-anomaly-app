import 'package:flutter_test/flutter_test.dart';
import 'package:market_anomaly/models.dart';

void main() {
  test('decodifica una serie prezzi completa', () {
    final history = PriceHistoryData.fromJson({
      'ticker': 'META',
      'provider_ticker': 'META.US',
      'period': '1M',
      'points': [
        {
          'time': '2026-08-24T00:00:00+00:00',
          'open': 550,
          'high': 565,
          'low': 548,
          'close': 559.02,
          'volume': 123456,
        },
      ],
      'summary': {
        'first_close': 550,
        'last_close': 559.02,
        'change_pct': 1.64,
        'period_high': 565,
        'period_low': 548,
        'max_drawdown_pct': -2.1,
      },
      'note': null,
    });

    expect(history.ticker, 'META');
    expect(history.points, hasLength(1));
    expect(history.points.first.close, 559.02);
    expect(history.summary.changePct, 1.64);
  });

  test('decodifica un risultato di ricerca', () {
    final result = SearchTickerResult.fromJson({
      'ticker': 'NVDA',
      'provider_ticker': 'NVDA.US',
      'company': 'NVIDIA',
      'exchange': 'US',
      'type': 'Common Stock',
    });

    expect(result.ticker, 'NVDA');
    expect(result.providerTicker, 'NVDA.US');
    expect(result.company, 'NVIDIA');
  });
}
