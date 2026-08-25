/// Modelli dati che rispecchiano le risposte JSON del backend Market Anomaly.
/// Ogni campo è nullable dove il motore Python può restituire None/NaN.
library;

class DashboardStats {
  final int analyzed;
  final int candidates;
  final double? maxOpportunity;
  final double? maxAnomaly;
  final int stalePrices;
  final int failed;

  DashboardStats({
    required this.analyzed,
    required this.candidates,
    this.maxOpportunity,
    this.maxAnomaly,
    this.stalePrices = 0,
    this.failed = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        analyzed: (j['analyzed'] ?? 0) as int,
        candidates: (j['candidates'] ?? 0) as int,
        maxOpportunity: (j['max_opportunity'] as num?)?.toDouble(),
        maxAnomaly: (j['max_anomaly'] as num?)?.toDouble(),
        stalePrices: (j['stale_prices'] as num?)?.toInt() ?? 0,
        failed: (j['failed'] as num?)?.toInt() ?? 0,
      );
}

class AnomalyRow {
  final String ticker;
  final String company;
  final double? price;
  final double? drawdown52wPct;
  final double? anomalyScore;
  final double? opportunityScore;
  final double? valueTrapRisk;
  final double? valuationScore;
  final double? financialRiskScore;
  final double? distressRiskScore;
  final double? dilutionRiskScore;
  final double? confidenceScore;
  final String catalystLabel;
  final String classification;
  final String summary;
  final List<String> dataGaps;
  final String currency;
  final String exchange;
  final String sector;
  final String? priceObservedAt;
  final String priceSource;
  final String priceStatus;
  final double? priceAgeHours;
  final String? priceWarning;
  final bool inWatchlist;

  AnomalyRow({
    required this.ticker,
    required this.company,
    this.price,
    this.drawdown52wPct,
    this.anomalyScore,
    this.opportunityScore,
    this.valueTrapRisk,
    this.valuationScore,
    this.financialRiskScore,
    this.distressRiskScore,
    this.dilutionRiskScore,
    this.confidenceScore,
    required this.catalystLabel,
    required this.classification,
    required this.summary,
    required this.dataGaps,
    required this.currency,
    required this.exchange,
    required this.sector,
    this.priceObservedAt,
    required this.priceSource,
    required this.priceStatus,
    this.priceAgeHours,
    this.priceWarning,
    required this.inWatchlist,
  });

  factory AnomalyRow.fromJson(Map<String, dynamic> j) => AnomalyRow(
        ticker: j['ticker'] ?? '',
        company: j['company'] ?? '',
        price: (j['price'] as num?)?.toDouble(),
        drawdown52wPct: (j['drawdown_52w_pct'] as num?)?.toDouble(),
        anomalyScore: (j['anomaly_score'] as num?)?.toDouble(),
        opportunityScore: (j['opportunity_score'] as num?)?.toDouble(),
        valueTrapRisk: (j['value_trap_risk'] as num?)?.toDouble(),
        valuationScore: (j['valuation_score'] as num?)?.toDouble(),
        financialRiskScore: (j['financial_risk_score'] as num?)?.toDouble(),
        distressRiskScore: (j['distress_risk_score'] as num?)?.toDouble(),
        dilutionRiskScore: (j['dilution_risk_score'] as num?)?.toDouble(),
        confidenceScore: (j['confidence_score'] as num?)?.toDouble(),
        catalystLabel: j['catalyst_label'] ?? '',
        classification: j['classification'] ?? '',
        summary: j['summary']?.toString() ?? '',
        dataGaps: ((j['data_gaps'] ?? []) as List)
            .map((item) => item.toString())
            .toList(),
        currency: j['currency']?.toString() ?? 'USD',
        exchange: j['exchange']?.toString() ?? '',
        sector: j['sector']?.toString() ?? '',
        priceObservedAt: j['price_observed_at']?.toString(),
        priceSource: j['price_source']?.toString() ?? 'unknown',
        priceStatus: j['price_status']?.toString() ?? 'unknown',
        priceAgeHours: (j['price_age_hours'] as num?)?.toDouble(),
        priceWarning: j['price_warning']?.toString(),
        inWatchlist: j['in_watchlist'] == true,
      );
}

class MarketTensionData {
  final String? observedAt;
  final String status;
  final double? score;
  final String level;
  final double? valuationPressure;
  final double? priceEuphoria;
  final double? fragility;
  final double coveragePct;
  final double? valuationCoveragePct;
  final double? benchmarkCoveragePct;
  final int valuationCompanies;
  final Map<String, double> regionalValuation;
  final double? benchmarkBreadthAbove200dPct;
  final String source;
  final String dataDelayNote;
  final String methodologyVersion;
  final String explanation;
  final String historicalWarning;

  MarketTensionData({
    this.observedAt,
    required this.status,
    this.score,
    required this.level,
    this.valuationPressure,
    this.priceEuphoria,
    this.fragility,
    required this.coveragePct,
    this.valuationCoveragePct,
    this.benchmarkCoveragePct,
    required this.valuationCompanies,
    required this.regionalValuation,
    this.benchmarkBreadthAbove200dPct,
    required this.source,
    required this.dataDelayNote,
    required this.methodologyVersion,
    required this.explanation,
    required this.historicalWarning,
  });

  factory MarketTensionData.fromJson(Map<String, dynamic> j) {
    final regions = <String, double>{};
    final rawRegions = j['regional_valuation'];
    if (rawRegions is Map) {
      rawRegions.forEach((key, value) {
        if (value is num) regions[key.toString()] = value.toDouble();
      });
    }
    return MarketTensionData(
      observedAt: j['observed_at']?.toString(),
      status: j['status']?.toString() ?? 'unavailable',
      score: (j['score'] as num?)?.toDouble(),
      level: j['level']?.toString() ?? 'Non disponibile',
      valuationPressure: (j['valuation_pressure'] as num?)?.toDouble(),
      priceEuphoria: (j['price_euphoria'] as num?)?.toDouble(),
      fragility: (j['fragility'] as num?)?.toDouble(),
      coveragePct: (j['coverage_pct'] as num?)?.toDouble() ?? 0.0,
      valuationCoveragePct:
          (j['valuation_coverage_pct'] as num?)?.toDouble(),
      benchmarkCoveragePct:
          (j['benchmark_coverage_pct'] as num?)?.toDouble(),
      valuationCompanies: (j['valuation_companies'] as num?)?.toInt() ?? 0,
      regionalValuation: regions,
      benchmarkBreadthAbove200dPct:
          (j['benchmark_breadth_above_200d_pct'] as num?)?.toDouble(),
      source: j['source']?.toString() ?? 'unknown',
      dataDelayNote: j['data_delay_note']?.toString() ?? '',
      methodologyVersion: j['methodology_version']?.toString() ?? '',
      explanation: j['explanation']?.toString() ?? '',
      historicalWarning: j['historical_warning']?.toString() ?? '',
    );
  }
}

class DashboardData {
  final String? scanTime;
  final String? marketMode;
  final List<AnomalyRow> topAnomalies;
  final DashboardStats stats;
  final MarketTensionData marketTension;

  DashboardData({
    required this.scanTime,
    required this.marketMode,
    required this.topAnomalies,
    required this.stats,
    required this.marketTension,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        scanTime: j['scan_time'],
        marketMode: j['market_mode'],
        topAnomalies: ((j['top_anomalies'] ?? []) as List)
            .map((e) => AnomalyRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        stats: DashboardStats.fromJson(j['stats'] ?? {}),
        marketTension: MarketTensionData.fromJson(
          (j['market_tension'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
        ),
      );
}

class TickerNarrative {
  final String classificationLabel;
  final double classificationScore;
  final List<String> whyAnomaly;
  final List<String> whyNot;
  final String summary;
  final List<String> dataGaps;
  final String? sectorContext;

  TickerNarrative({
    required this.classificationLabel,
    required this.classificationScore,
    required this.whyAnomaly,
    required this.whyNot,
    required this.summary,
    required this.dataGaps,
    this.sectorContext,
  });

  factory TickerNarrative.fromJson(Map<String, dynamic> j) => TickerNarrative(
        classificationLabel: (j['classification']?['label']) ?? '',
        classificationScore:
            ((j['classification']?['score']) as num?)?.toDouble() ?? 0.0,
        whyAnomaly: ((j['why_anomaly'] ?? []) as List).map((e) => e.toString()).toList(),
        whyNot: ((j['why_not'] ?? []) as List).map((e) => e.toString()).toList(),
        summary: j['summary']?.toString() ?? '',
        dataGaps: ((j['data_gaps'] ?? []) as List)
            .map((e) => e.toString())
            .toList(),
        sectorContext: j['sector_context']?.toString(),
      );
}

class TickerDetail {
  final Map<String, dynamic> raw;
  final TickerNarrative narrative;
  final bool inWatchlist;

  TickerDetail({required this.raw, required this.narrative, required this.inWatchlist});

  factory TickerDetail.fromJson(Map<String, dynamic> j) => TickerDetail(
        raw: j,
        narrative: TickerNarrative.fromJson(j['narrative'] ?? {}),
        inWatchlist: j['in_watchlist'] == true,
      );

  String get ticker => raw['ticker'] ?? '';
  String get company => raw['company'] ?? '';
  double? get lastClose => (raw['last_close'] as num?)?.toDouble();
  double? get drawdown52wPct => (raw['drawdown_52w_pct'] as num?)?.toDouble();
  double? get anomalyScore => (raw['anomaly_score'] as num?)?.toDouble();
  double? get opportunityScore => (raw['opportunity_score'] as num?)?.toDouble();
  double? get valueTrapRisk => (raw['value_trap_risk'] as num?)?.toDouble();
  double? get catalystRisk => (raw['catalyst_risk'] as num?)?.toDouble();
  double? get qualityScore => (raw['quality_score'] as num?)?.toDouble();
  double? get valuationScore => (raw['valuation_score'] as num?)?.toDouble();
  double? get financialRiskScore => (raw['financial_risk_score'] as num?)?.toDouble();
  double? get distressRiskScore => (raw['distress_risk_score'] as num?)?.toDouble();
  double? get dilutionRiskScore => (raw['dilution_risk_score'] as num?)?.toDouble();
  double? get confidenceScore => (raw['confidence_score'] as num?)?.toDouble();
  double? get peRatio => (raw['pe_ratio'] as num?)?.toDouble();
  double? get priceToSales => (raw['price_to_sales'] as num?)?.toDouble();
  double? get fcfYieldPct => (raw['fcf_yield_pct'] as num?)?.toDouble();
  double? get marketCap => (raw['market_cap'] as num?)?.toDouble();
  double? get marketCapUsd => (raw['market_cap_usd'] as num?)?.toDouble();
  String? get fundamentalsError => raw['fundamentals_error']?.toString();
  double? get revenueGrowthPct => (raw['revenue_growth_pct'] as num?)?.toDouble();
  double? get netMarginPct => (raw['net_margin_pct'] as num?)?.toDouble();
  double? get liabilitiesToAssets => (raw['liabilities_to_assets'] as num?)?.toDouble();
  double? get fcfMarginPct => (raw['fcf_margin_pct'] as num?)?.toDouble();
  double? get recoveryPotential => (raw['recovery_potential'] as num?)?.toDouble();
  String get catalystLabel => raw['catalyst_label'] ?? '';
  String get catalystExplanation => raw['catalyst_explanation'] ?? '';
  String get explanation => raw['explanation'] ?? '';
  String get sectorEtf => raw['sector_etf'] ?? '';
  String get currency => raw['currency']?.toString() ?? 'USD';
  String get exchange =>
      raw['light_exchange']?.toString() ?? raw['exchange']?.toString() ?? '';
  String get sector =>
      raw['light_sector']?.toString() ?? raw['sector']?.toString() ?? '';
  String get priceStatus => raw['price_status']?.toString() ?? 'unknown';
  String get priceSource => raw['price_source']?.toString() ?? 'unknown';
  String? get priceObservedAt => raw['price_observed_at']?.toString();
  double? get priceAgeHours => (raw['price_age_hours'] as num?)?.toDouble();
  String? get priceWarning => raw['price_warning']?.toString();
  String get fundamentalsSource =>
      raw['fundamentals_source']?.toString() ?? 'non disponibile';
  String? get fundamentalsPeriodEnd =>
      raw['fundamentals_period_end']?.toString();
  String get modelVersion => raw['model_version']?.toString() ?? 'n/d';
  double? get dataCompletenessPct {
    final rawCompleteness = raw['data_completeness'];
    if (rawCompleteness is! Map) return null;
    final available = (rawCompleteness['available_fields'] as num?)?.toDouble();
    final total = (rawCompleteness['total_fields'] as num?)?.toDouble();
    if (available == null || total == null || total <= 0) return null;
    return available / total * 100.0;
  }
  List<String> get missingFundamentalFields =>
      ((raw['missing_fundamental_fields'] ?? []) as List)
          .map((item) => item.toString())
          .toList();
}

class WatchlistItem {
  final String ticker;
  final String? company;
  final String? addedAt;
  final double? priceAtAdd;
  final double? currentPrice;
  final double? performancePct;
  final double? anomalyScoreAtAdd;
  final double? anomalyScoreNow;
  final double? opportunityScoreAtAdd;
  final double? opportunityScoreNow;
  final String currency;
  final String priceStatus;
  final String? priceObservedAt;
  final String catalystLabelAtAdd;
  final String catalystLabelNow;
  final bool hasNewEvent;

  WatchlistItem({
    required this.ticker,
    this.company,
    this.addedAt,
    this.priceAtAdd,
    this.currentPrice,
    this.performancePct,
    this.anomalyScoreAtAdd,
    this.anomalyScoreNow,
    this.opportunityScoreAtAdd,
    this.opportunityScoreNow,
    this.currency = 'USD',
    this.priceStatus = 'unknown',
    this.priceObservedAt,
    this.catalystLabelAtAdd = '',
    this.catalystLabelNow = '',
    this.hasNewEvent = false,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> j) => WatchlistItem(
        ticker: j['ticker'] ?? '',
        company: j['company'],
        addedAt: j['added_at'],
        priceAtAdd: (j['price_at_add'] as num?)?.toDouble(),
        currentPrice: (j['current_price'] as num?)?.toDouble(),
        performancePct: (j['performance_pct'] as num?)?.toDouble(),
        anomalyScoreAtAdd: (j['anomaly_score_at_add'] as num?)?.toDouble(),
        anomalyScoreNow: (j['anomaly_score_now'] as num?)?.toDouble(),
        opportunityScoreAtAdd: (j['opportunity_score_at_add'] as num?)?.toDouble(),
        opportunityScoreNow: (j['opportunity_score_now'] as num?)?.toDouble(),
        currency: j['currency']?.toString() ?? 'USD',
        priceStatus: j['price_status']?.toString() ?? 'unknown',
        priceObservedAt: j['price_observed_at']?.toString(),
        catalystLabelAtAdd:
            j['catalyst_label_at_add']?.toString() ?? '',
        catalystLabelNow:
            j['catalyst_label_now']?.toString() ?? '',
        hasNewEvent: j['has_new_event'] == true,
      );
}

class HistoryOutcome {
  final int horizonSessions;
  final String status;
  final String? dueAt;
  final String? evaluatedAt;
  final double? outcomePrice;
  final double? absoluteReturnPct;
  final double? benchmarkReturnPct;
  final double? relativeReturnPct;
  final double? maxDrawdownPct;
  final bool? recovered;
  final int? recoverySessions;

  HistoryOutcome({
    required this.horizonSessions,
    required this.status,
    this.dueAt,
    this.evaluatedAt,
    this.outcomePrice,
    this.absoluteReturnPct,
    this.benchmarkReturnPct,
    this.relativeReturnPct,
    this.maxDrawdownPct,
    this.recovered,
    this.recoverySessions,
  });

  factory HistoryOutcome.fromJson(Map<String, dynamic> j) => HistoryOutcome(
        horizonSessions: (j['horizon_sessions'] as num?)?.toInt() ?? 0,
        status: j['status']?.toString() ?? 'pending',
        dueAt: j['due_at']?.toString(),
        evaluatedAt: j['evaluated_at']?.toString(),
        outcomePrice: (j['outcome_price'] as num?)?.toDouble(),
        absoluteReturnPct:
            (j['absolute_return_pct'] as num?)?.toDouble(),
        benchmarkReturnPct:
            (j['benchmark_return_pct'] as num?)?.toDouble(),
        relativeReturnPct:
            (j['relative_return_pct'] as num?)?.toDouble(),
        maxDrawdownPct: (j['max_drawdown_pct'] as num?)?.toDouble(),
        recovered: j['recovered'] as bool?,
        recoverySessions: (j['recovery_sessions'] as num?)?.toInt(),
      );
}

class HistoryEntry {
  final String signalTime;
  final String ticker;
  final String? company;
  final double? price;
  final double? anomalyScore;
  final double? opportunityScore;
  final double? recoveryPotential;
  final double? valueTrapRisk;
  final double? catalystRisk;
  final double? qualityScore;
  final double? confidenceScore;
  final String currency;
  final String catalystLabel;
  final String modelVersion;
  final List<HistoryOutcome> outcomes;

  HistoryEntry({
    required this.signalTime,
    required this.ticker,
    this.company,
    this.price,
    this.anomalyScore,
    this.opportunityScore,
    this.recoveryPotential,
    this.valueTrapRisk,
    this.catalystRisk,
    this.qualityScore,
    this.confidenceScore,
    this.currency = 'USD',
    this.catalystLabel = '',
    this.modelVersion = '',
    this.outcomes = const [],
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        signalTime: j['signal_time'] ?? '',
        ticker: j['ticker'] ?? '',
        company: j['company'],
        price: (j['price'] as num?)?.toDouble(),
        anomalyScore: (j['anomaly_score'] as num?)?.toDouble(),
        opportunityScore: (j['opportunity_score'] as num?)?.toDouble(),
        recoveryPotential: (j['recovery_potential'] as num?)?.toDouble(),
        valueTrapRisk: (j['value_trap_risk'] as num?)?.toDouble(),
        catalystRisk: (j['catalyst_risk'] as num?)?.toDouble(),
        qualityScore: (j['quality_score'] as num?)?.toDouble(),
        confidenceScore: (j['confidence_score'] as num?)?.toDouble(),
        currency: j['currency']?.toString() ?? 'USD',
        catalystLabel: j['catalyst_label']?.toString() ?? '',
        modelVersion: j['model_version']?.toString() ?? '',
        outcomes: ((j['outcomes'] ?? []) as List)
            .map(
              (item) => HistoryOutcome.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
}

class SearchTickerResult {
  final String ticker;
  final String providerTicker;
  final String company;
  final String exchange;
  final String type;

  SearchTickerResult({
    required this.ticker,
    required this.providerTicker,
    required this.company,
    required this.exchange,
    required this.type,
  });

  factory SearchTickerResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchTickerResult(
      ticker: json['ticker']?.toString() ?? '',
      providerTicker:
          json['provider_ticker']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      exchange: json['exchange']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

class PricePoint {
  final DateTime time;
  final double close;
  final double? open;
  final double? high;
  final double? low;
  final double volume;

  PricePoint({
    required this.time,
    required this.close,
    this.open,
    this.high,
    this.low,
    required this.volume,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      time: DateTime.tryParse(json['time']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      close: (json['close'] as num?)?.toDouble() ?? 0,
      open: (json['open'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PriceHistorySummary {
  final double? firstClose;
  final double? lastClose;
  final double? changePct;
  final double? periodHigh;
  final double? periodLow;
  final double? maxDrawdownPct;
  final double? currentPrice;
  final String? currentPriceObservedAt;
  final String? currentPriceSource;

  PriceHistorySummary({
    this.firstClose,
    this.lastClose,
    this.changePct,
    this.periodHigh,
    this.periodLow,
    this.maxDrawdownPct,
    this.currentPrice,
    this.currentPriceObservedAt,
    this.currentPriceSource,
  });

  factory PriceHistorySummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return PriceHistorySummary(
      firstClose: (json['first_close'] as num?)?.toDouble(),
      lastClose: (json['last_close'] as num?)?.toDouble(),
      changePct: (json['change_pct'] as num?)?.toDouble(),
      periodHigh: (json['period_high'] as num?)?.toDouble(),
      periodLow: (json['period_low'] as num?)?.toDouble(),
      maxDrawdownPct:
          (json['max_drawdown_pct'] as num?)?.toDouble(),
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      currentPriceObservedAt:
          json['current_price_observed_at']?.toString(),
      currentPriceSource: json['current_price_source']?.toString(),
    );
  }
}

class PriceHistoryData {
  final String ticker;
  final String providerTicker;
  final String period;
  final String currency;
  final String seriesType;
  final List<PricePoint> points;
  final PriceHistorySummary summary;
  final String? note;

  PriceHistoryData({
    required this.ticker,
    required this.providerTicker,
    required this.period,
    required this.currency,
    required this.seriesType,
    required this.points,
    required this.summary,
    this.note,
  });

  factory PriceHistoryData.fromJson(Map<String, dynamic> json) {
    return PriceHistoryData(
      ticker: json['ticker']?.toString() ?? '',
      providerTicker:
          json['provider_ticker']?.toString() ?? '',
      period: json['period']?.toString() ?? '1M',
      currency: json['currency']?.toString() ?? 'USD',
      seriesType: json['series_type']?.toString() ?? 'unknown',
      points: ((json['points'] ?? []) as List)
          .map(
            (item) => PricePoint.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      summary: PriceHistorySummary.fromJson(
        (json['summary'] ?? {}) as Map<String, dynamic>,
      ),
      note: json['note']?.toString(),
    );
  }
}
