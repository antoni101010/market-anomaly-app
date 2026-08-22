/// Modelli dati che rispecchiano le risposte JSON del backend Market Anomaly.
/// Ogni campo è nullable dove il motore Python può restituire None/NaN.
library;

class DashboardStats {
  final int analyzed;
  final int candidates;
  final double? maxOpportunity;
  final double? maxAnomaly;

  DashboardStats({
    required this.analyzed,
    required this.candidates,
    this.maxOpportunity,
    this.maxAnomaly,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        analyzed: (j['analyzed'] ?? 0) as int,
        candidates: (j['candidates'] ?? 0) as int,
        maxOpportunity: (j['max_opportunity'] as num?)?.toDouble(),
        maxAnomaly: (j['max_anomaly'] as num?)?.toDouble(),
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
  final String catalystLabel;
  final String classification;
  final bool inWatchlist;

  AnomalyRow({
    required this.ticker,
    required this.company,
    this.price,
    this.drawdown52wPct,
    this.anomalyScore,
    this.opportunityScore,
    this.valueTrapRisk,
    required this.catalystLabel,
    required this.classification,
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
        catalystLabel: j['catalyst_label'] ?? '',
        classification: j['classification'] ?? '',
        inWatchlist: j['in_watchlist'] == true,
      );
}

class DashboardData {
  final String? scanTime;
  final String? marketMode;
  final List<AnomalyRow> topAnomalies;
  final DashboardStats stats;

  DashboardData({
    required this.scanTime,
    required this.marketMode,
    required this.topAnomalies,
    required this.stats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
        scanTime: j['scan_time'],
        marketMode: j['market_mode'],
        topAnomalies: ((j['top_anomalies'] ?? []) as List)
            .map((e) => AnomalyRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        stats: DashboardStats.fromJson(j['stats'] ?? {}),
      );
}

class TickerNarrative {
  final String classificationLabel;
  final double classificationScore;
  final List<String> whyAnomaly;
  final List<String> whyNot;

  TickerNarrative({
    required this.classificationLabel,
    required this.classificationScore,
    required this.whyAnomaly,
    required this.whyNot,
  });

  factory TickerNarrative.fromJson(Map<String, dynamic> j) => TickerNarrative(
        classificationLabel: (j['classification']?['label']) ?? '',
        classificationScore:
            ((j['classification']?['score']) as num?)?.toDouble() ?? 0.0,
        whyAnomaly: ((j['why_anomaly'] ?? []) as List).map((e) => e.toString()).toList(),
        whyNot: ((j['why_not'] ?? []) as List).map((e) => e.toString()).toList(),
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
  double? get revenueGrowthPct => (raw['revenue_growth_pct'] as num?)?.toDouble();
  double? get netMarginPct => (raw['net_margin_pct'] as num?)?.toDouble();
  double? get liabilitiesToAssets => (raw['liabilities_to_assets'] as num?)?.toDouble();
  double? get fcfMarginPct => (raw['fcf_margin_pct'] as num?)?.toDouble();
  double? get recoveryPotential => (raw['recovery_potential'] as num?)?.toDouble();
  String get catalystLabel => raw['catalyst_label'] ?? '';
  String get catalystExplanation => raw['catalyst_explanation'] ?? '';
  String get explanation => raw['explanation'] ?? '';
  String get sectorEtf => raw['sector_etf'] ?? '';
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
      );
}
