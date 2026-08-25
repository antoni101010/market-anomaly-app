import 'package:flutter_test/flutter_test.dart';
import 'package:market_anomaly/legal_content.dart';
import 'package:market_anomaly/models.dart';

void main() {
  test('dashboard decodifica la tensione globale e la copertura', () {
    final dashboard = DashboardData.fromJson({
      'scan_time': '2026-08-25T10:00:00Z',
      'market_mode': 'live',
      'top_anomalies': [],
      'stats': {'analyzed': 100, 'candidates': 4},
      'market_tension': {
        'observed_at': '2026-08-25T09:00:00Z',
        'status': 'complete',
        'score': 72.4,
        'level': 'Molto elevata',
        'valuation_pressure': 81.0,
        'price_euphoria': 70.0,
        'fragility': 58.0,
        'coverage_pct': 91.5,
        'valuation_coverage_pct': 88.0,
        'benchmark_coverage_pct': 98.0,
        'valuation_companies': 84,
        'regional_valuation': {'USA': 86.0, 'Europa': 62.0},
        'source': 'eodhd',
        'data_delay_note': 'Dati EOD.',
        'methodology_version': 'market-tension-1.0',
        'explanation': 'Tensione statistica elevata.',
        'historical_warning': 'Il passato non garantisce il futuro.',
      },
    });

    expect(dashboard.marketTension.score, 72.4);
    expect(dashboard.marketTension.coveragePct, 91.5);
    expect(dashboard.marketTension.regionalValuation['USA'], 86.0);
  });

  test('testi legali correnti mantengono posizionamento statistico neutrale', () {
    expect(LegalContent.termsVersion, '2026-08-25-v1');
    expect(LegalContent.shortFinancialNotice, contains('analisi statistica'));
    expect(LegalContent.shortFinancialNotice, contains('Non fornisce consulenza'));
    expect(LegalContent.methodology, contains('Somiglianza con casi storici'));
    expect(LegalContent.methodology, contains('Tensione globale dei mercati'));
  });
}
