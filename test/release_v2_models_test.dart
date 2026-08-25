import 'package:flutter_test/flutter_test.dart';
import 'package:market_anomaly/analysis_preferences.dart';
import 'package:market_anomaly/models.dart';

void main() {
  test('dashboard conserva valuta, fonte prezzo e testo specifico', () {
    final row = AnomalyRow.fromJson({
      'ticker': 'SAP',
      'company': 'SAP SE',
      'price': 190.5,
      'currency': 'EUR',
      'classification': 'DA APPROFONDIRE',
      'summary': 'Sottoperformance settoriale con valutazione disponibile.',
      'data_gaps': ['copertura degli interessi'],
      'price_status': 'delayed',
      'price_source': 'eodhd_live_or_delayed',
      'price_observed_at': '2026-08-25T10:00:00+00:00',
      'catalyst_label': 'Causa non classificata',
      'in_watchlist': false,
    });

    expect(row.currency, 'EUR');
    expect(row.priceStatus, 'delayed');
    expect(row.summary, contains('Sottoperformance'));
    expect(row.dataGaps.single, 'copertura degli interessi');
  });

  test('grafico distingue serie rettificata e quota corrente', () {
    final history = PriceHistoryData.fromJson({
      'ticker': 'SAP',
      'provider_ticker': 'SAP.XETRA',
      'period': '1M',
      'currency': 'EUR',
      'series_type': 'provider_adjusted_history',
      'points': [
        {'time': '2026-08-24T00:00:00Z', 'close': 188, 'volume': 1},
        {'time': '2026-08-25T00:00:00Z', 'close': 190, 'volume': 1},
      ],
      'summary': {
        'current_price': 190.5,
        'current_price_source': 'eodhd_live_or_delayed',
        'current_price_observed_at': '2026-08-25T10:00:00Z',
      },
    });

    expect(history.currency, 'EUR');
    expect(history.seriesType, 'provider_adjusted_history');
    expect(history.summary.currentPrice, 190.5);
  });

  test('storico decodifica esiti reali multi-orizzonte', () {
    final entry = HistoryEntry.fromJson({
      'signal_time': '2026-08-25T10:00:00Z',
      'ticker': 'SAP',
      'company': 'SAP SE',
      'price': 190.5,
      'currency': 'EUR',
      'anomaly_score': 64,
      'opportunity_score': 58,
      'catalyst_label': 'Causa non classificata',
      'model_version': 'ma-core-2.0.0',
      'outcomes': [
        {
          'horizon_sessions': 1,
          'status': 'complete',
          'absolute_return_pct': 2.4,
          'relative_return_pct': 1.1,
          'max_drawdown_pct': -0.8,
          'recovered': true,
          'recovery_sessions': 1,
        },
        {
          'horizon_sessions': 30,
          'status': 'pending',
        },
      ],
    });

    expect(entry.outcomes, hasLength(2));
    expect(entry.outcomes.first.horizonSessions, 1);
    expect(entry.outcomes.first.absoluteReturnPct, 2.4);
    expect(entry.outcomes.last.status, 'pending');
  });

  test('watchlist segnala un evento cambiato', () {
    final item = WatchlistItem.fromJson({
      'ticker': 'SAP',
      'currency': 'EUR',
      'catalyst_label_at_add': 'Nessun catalizzatore disponibile',
      'catalyst_label_now': 'Causa non classificata',
      'has_new_event': true,
    });

    expect(item.hasNewEvent, isTrue);
    expect(item.catalystLabelNow, 'Causa non classificata');
  });

  test('preferenze avanzate mantengono filtri e modalità', () {
    final preferences = AnalysisPreferences.fromJson({
      'simpleMode': false,
      'minValuation': 55,
      'minDrawdownPct': 25,
      'minAverageVolume': 500000,
      'eventFilter': 'earnings',
    });

    expect(preferences.simpleMode, isFalse);
    expect(preferences.minValuation, 55);
    expect(preferences.minDrawdownPct, 25);
    expect(preferences.minAverageVolume, 500000);
    expect(preferences.eventFilter, 'earnings');
  });
}
