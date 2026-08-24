/// Modelli dati delle risposte JSON
/// del backend Market Anomaly.
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

  factory DashboardStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardStats(
      analyzed: (
        json['analyzed']
        ?? 0
      ) as int,
      candidates: (
        json['candidates']
        ?? 0
      ) as int,
      maxOpportunity: (
        json['max_opportunity']
        as num?
      )?.toDouble(),
      maxAnomaly: (
        json['max_anomaly']
        as num?
      )?.toDouble(),
    );
  }
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
  final bool inWatchlist;

  AnomalyRow({
    required this.ticker,
    required this.company,
    required this.catalystLabel,
    required this.classification,
    required this.inWatchlist,
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
  });

  factory AnomalyRow.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnomalyRow(
      ticker: json['ticker'] ?? '',
      company: json['company'] ?? '',
      price: (
        json['price']
        as num?
      )?.toDouble(),
      drawdown52wPct: (
        json['drawdown_52w_pct']
        as num?
      )?.toDouble(),
      anomalyScore: (
        json['anomaly_score']
        as num?
      )?.toDouble(),
      opportunityScore: (
        json['opportunity_score']
        as num?
      )?.toDouble(),
      valueTrapRisk: (
        json['value_trap_risk']
        as num?
      )?.toDouble(),
      valuationScore: (
        json['valuation_score']
        as num?
      )?.toDouble(),
      financialRiskScore: (
        json['financial_risk_score']
        as num?
      )?.toDouble(),
      distressRiskScore: (
        json['distress_risk_score']
        as num?
      )?.toDouble(),
      dilutionRiskScore: (
        json['dilution_risk_score']
        as num?
      )?.toDouble(),
      confidenceScore: (
        json['confidence_score']
        as num?
      )?.toDouble(),
      catalystLabel: (
        json['catalyst_label']
        ?? ''
      ),
      classification: (
        json['classification']
        ?? ''
      ),
      inWatchlist: (
        json['in_watchlist']
        == true
      ),
    );
  }
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

  factory DashboardData.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardData(
      scanTime: json['scan_time'],
      marketMode: json['market_mode'],
      topAnomalies: (
        (
          json['top_anomalies']
          ?? []
        ) as List
      ).map(
        (item) => AnomalyRow.fromJson(
          item as Map<String, dynamic>,
        ),
      ).toList(),
      stats: DashboardStats.fromJson(
        json['stats']
        ?? {},
      ),
    );
  }
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

  factory TickerNarrative.fromJson(
    Map<String, dynamic> json,
  ) {
    return TickerNarrative(
      classificationLabel: (
        json['classification']
        ?['label']
        ?? ''
      ),
      classificationScore: (
        json['classification']
        ?['score']
        as num?
      )?.toDouble()
          ?? 0.0,
      whyAnomaly: (
        (
          json['why_anomaly']
          ?? []
        ) as List
      ).map(
        (item) => item.toString(),
      ).toList(),
      whyNot: (
        (
          json['why_not']
          ?? []
        ) as List
      ).map(
        (item) => item.toString(),
      ).toList(),
    );
  }
}


class TickerDetail {
  final Map<String, dynamic> raw;
  final TickerNarrative narrative;
  final bool inWatchlist;

  TickerDetail({
    required this.raw,
    required this.narrative,
    required this.inWatchlist,
  });

  factory TickerDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    return TickerDetail(
      raw: json,
      narrative: TickerNarrative.fromJson(
        json['narrative']
        ?? {},
      ),
      inWatchlist: (
        json['in_watchlist']
        == true
      ),
    );
  }

  String get ticker =>
      raw['ticker'] ?? '';

  String get company =>
      raw['company'] ?? '';

  double? get lastClose =>
      (raw['last_close'] as num?)
          ?.toDouble();

  double? get drawdown52wPct =>
      (raw['drawdown_52w_pct'] as num?)
          ?.toDouble();

  double? get anomalyScore =>
      (raw['anomaly_score'] as num?)
          ?.toDouble();

  double? get opportunityScore =>
      (raw['opportunity_score'] as num?)
          ?.toDouble();

  double? get valueTrapRisk =>
      (raw['value_trap_risk'] as num?)
          ?.toDouble();

  double? get catalystRisk =>
      (raw['catalyst_risk'] as num?)
          ?.toDouble();

  double? get qualityScore =>
      (raw['quality_score'] as num?)
          ?.toDouble();

  double? get valuationScore =>
      (raw['valuation_score'] as num?)
          ?.toDouble();

  double? get financialRiskScore =>
      (raw['financial_risk_score'] as num?)
          ?.toDouble();

  double? get distressRiskScore =>
      (raw['distress_risk_score'] as num?)
          ?.toDouble();

  double? get dilutionRiskScore =>
      (raw['dilution_risk_score'] as num?)
          ?.toDouble();

  double? get confidenceScore =>
      (raw['confidence_score'] as num?)
          ?.toDouble();

  double? get peRatio =>
      (raw['pe_ratio'] as num?)
          ?.toDouble();

  double? get priceToSales =>
      (raw['price_to_sales'] as num?)
          ?.toDouble();

  double? get fcfYieldPct =>
      (raw['fcf_yield_pct'] as num?)
          ?.toDouble();

  double? get marketCap =>
      (raw['market_cap'] as num?)
          ?.toDouble();

  double? get revenueGrowthPct =>
      (raw['revenue_growth_pct'] as num?)
          ?.toDouble();

  double? get netMarginPct =>
      (raw['net_margin_pct'] as num?)
          ?.toDouble();

  double? get liabilitiesToAssets =>
      (raw['liabilities_to_assets'] as num?)
          ?.toDouble();

  double? get fcfMarginPct =>
      (raw['fcf_margin_pct'] as num?)
          ?.toDouble();

  double? get recoveryPotential =>
      (raw['recovery_potential'] as num?)
          ?.toDouble();

  String? get fundamentalsError =>
      raw['fundamentals_error']
          ?.toString();

  String get catalystLabel =>
      raw['catalyst_label'] ?? '';

  String get catalystExplanation =>
      raw['catalyst_explanation'] ?? '';

  String get explanation =>
      raw['explanation'] ?? '';

  String get sectorEtf =>
      raw['sector_etf'] ?? '';
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

  factory WatchlistItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return WatchlistItem(
      ticker: json['ticker'] ?? '',
      company: json['company'],
      addedAt: json['added_at'],
      priceAtAdd: (
        json['price_at_add']
        as num?
      )?.toDouble(),
      currentPrice: (
        json['current_price']
        as num?
      )?.toDouble(),
      performancePct: (
        json['performance_pct']
        as num?
      )?.toDouble(),
      anomalyScoreAtAdd: (
        json['anomaly_score_at_add']
        as num?
      )?.toDouble(),
      anomalyScoreNow: (
        json['anomaly_score_now']
        as num?
      )?.toDouble(),
      opportunityScoreAtAdd: (
        json['opportunity_score_at_add']
        as num?
      )?.toDouble(),
      opportunityScoreNow: (
        json['opportunity_score_now']
        as num?
      )?.toDouble(),
    );
  }
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

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistoryEntry(
      signalTime: (
        json['signal_time']
        ?? ''
      ),
      ticker: (
        json['ticker']
        ?? ''
      ),
      company: json['company'],
      price: (
        json['price']
        as num?
      )?.toDouble(),
      anomalyScore: (
        json['anomaly_score']
        as num?
      )?.toDouble(),
      opportunityScore: (
        json['opportunity_score']
        as num?
      )?.toDouble(),
      recoveryPotential: (
        json['recovery_potential']
        as num?
      )?.toDouble(),
      valueTrapRisk: (
        json['value_trap_risk']
        as num?
      )?.toDouble(),
      catalystRisk: (
        json['catalyst_risk']
        as num?
      )?.toDouble(),
      qualityScore: (
        json['quality_score']
        as num?
      )?.toDouble(),
    );
  }
}
