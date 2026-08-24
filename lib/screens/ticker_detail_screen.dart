import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme.dart';

class TickerDetailScreen extends StatefulWidget {
  final String ticker;

  const TickerDetailScreen({
    super.key,
    required this.ticker,
  });

  @override
  State<TickerDetailScreen> createState() =>
      _TickerDetailScreenState();
}

class _TickerDetailScreenState
    extends State<TickerDetailScreen> {
  TickerDetail? _detail;

  bool _loading = true;
  bool _watchlistBusy = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final detail =
          await ApiClient.instance
              .getTickerDetail(
        widget.ticker,
      );

      if (!mounted) return;

      setState(() {
        _detail = detail;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleWatchlist() async {
    final detail = _detail;

    if (detail == null ||
        _watchlistBusy) {
      return;
    }

    setState(() {
      _watchlistBusy = true;
    });

    try {
      if (detail.inWatchlist) {
        await ApiClient.instance
            .removeFromWatchlist(
          detail.ticker,
        );
      } else {
        await ApiClient.instance
            .addToWatchlist(
          detail.ticker,
        );
      }

      await _load();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _watchlistBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticker),
        actions: [
          if (_detail != null)
            IconButton(
              tooltip:
                  _detail!.inWatchlist
                      ? 'Rimuovi dalla watchlist'
                      : 'Aggiungi alla watchlist',
              onPressed:
                  _watchlistBusy
                      ? null
                      : _toggleWatchlist,
              icon: _watchlistBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _detail!.inWatchlist
                          ? Icons.star
                          : Icons.star_border,
                      color:
                          _detail!.inWatchlist
                              ? Colors.amber
                              : null,
                    ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title:
            'Impossibile caricare i dati',
        subtitle: _error,
        actionLabel: 'Riprova',
        onAction: _load,
      );
    }

    final detail = _detail;

    if (detail == null) {
      return const SizedBox.shrink();
    }

    final color =
        classificationColor(
      detail.narrative
          .classificationLabel,
    );

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        children: [
          _header(detail),
          const SizedBox(height: 16),
          _conclusionCard(
            detail,
            color,
          ),
          const SizedBox(height: 14),
          _mainScores(detail),
          const SizedBox(height: 24),
          _sectionTitle(
            'Perché è un movimento anomalo',
            Icons.trending_down,
            Colors.greenAccent,
          ),
          if (detail
              .narrative
              .whyAnomaly
              .isEmpty)
            _emptyText(
              'Nessun segnale rilevato.',
            )
          else
            ...detail
                .narrative
                .whyAnomaly
                .map(
              (text) => _bullet(
                text,
                Colors.greenAccent,
              ),
            ),
          const SizedBox(height: 20),
          _sectionTitle(
            'Perché serve cautela',
            Icons.warning_amber_outlined,
            Colors.orangeAccent,
          ),
          if (detail
              .narrative
              .whyNot
              .isEmpty)
            _emptyText(
              'Nessuna criticità '
              'specifica rilevata.',
            )
          else
            ...detail
                .narrative
                .whyNot
                .map(
              (text) => _bullet(
                text,
                Colors.orangeAccent,
              ),
            ),
          const SizedBox(height: 20),
          _advancedData(detail),
          const SizedBox(height: 24),
          Text(
            'Analisi quantitativa a scopo '
            'di ricerca. Non costituisce '
            'consulenza finanziaria né '
            'raccomandazione di acquisto '
            'o vendita.',
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 11,
              fontStyle:
                  FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(
    TickerDetail detail,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                detail.company,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail.sectorEtf.isEmpty
                    ? detail.ticker
                    : '${detail.ticker} · '
                        'confronto '
                        '${detail.sectorEtf}',
                style: TextStyle(
                  color:
                      Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              _priceText(
                detail.lastClose,
              ),
              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            if (detail
                    .drawdown52wPct !=
                null)
              Text(
                '${detail.drawdown52wPct!.toStringAsFixed(1)}% '
                'dal massimo 52 settimane',
                style: const TextStyle(
                  color:
                      Colors.redAccent,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _conclusionCard(
    TickerDetail detail,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.13,
        ),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail
                      .narrative
                      .classificationLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${_scoreText(detail.opportunityScore)}/100',
                style: TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _conclusion(detail),
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Il ribasso e la convenienza '
            'sono misurati separatamente: '
            'un titolo può essere sceso '
            'molto e risultare ancora costoso.',
            style: TextStyle(
              color:
                  Colors.grey.shade400,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainScores(
    TickerDetail detail,
  ) {
    return Row(
      children: [
        Expanded(
          child: ScoreBadge(
            label: 'Anomalia',
            value:
                detail.anomalyScore,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ScoreBadge(
            label: 'Valutazione',
            value:
                detail.valuationScore,
            color: _positiveScoreColor(
              detail.valuationScore,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ScoreBadge(
            label: 'Affidabilità',
            value:
                detail.confidenceScore,
            color: _positiveScoreColor(
              detail.confidenceScore,
            ),
          ),
        ),
      ],
    );
  }

  Widget _advancedData(
    TickerDetail detail,
  ) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(
          Icons.analytics_outlined,
        ),
        title: const Text(
          'Dati e rischi avanzati',
          style: TextStyle(
            fontWeight:
                FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: const Text(
          'Valutazione, fondamentali '
          'e qualità dei dati',
          style: TextStyle(
            fontSize: 11,
          ),
        ),
        tilePadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 3,
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          16,
        ),
        children: [
          _groupTitle('Punteggi'),
          _metricRow(
            'Opportunità',
            _scoreValue(
              detail.opportunityScore,
            ),
          ),
          _metricRow(
            'Potenziale recupero',
            _scoreValue(
              detail.recoveryPotential,
            ),
          ),
          _metricRow(
            'Qualità fondamentale',
            _scoreValue(
              detail.qualityScore,
            ),
          ),
          _metricRow(
            'Rischio value trap',
            _scoreValue(
              detail.valueTrapRisk,
            ),
          ),
          _metricRow(
            'Rischio finanziario',
            _scoreValue(
              detail.financialRiskScore,
            ),
          ),
          _metricRow(
            'Rischio deterioramento',
            _scoreValue(
              detail.distressRiskScore,
            ),
          ),
          _metricRow(
            'Rischio diluizione',
            _scoreValue(
              detail.dilutionRiskScore,
            ),
          ),
          _metricRow(
            'Rischio evento',
            _scoreValue(
              detail.catalystRisk,
            ),
          ),
          const Divider(height: 24),
          _groupTitle('Valutazione'),
          _metricRow(
            'P/E stimato',
            _numberValue(
              detail.peRatio,
              suffix: 'x',
            ),
          ),
          _metricRow(
            'Prezzo / ricavi',
            _numberValue(
              detail.priceToSales,
              suffix: 'x',
            ),
          ),
          _metricRow(
            'Rendimento free cash flow',
            _numberValue(
              detail.fcfYieldPct,
              suffix: '%',
            ),
          ),
          _metricRow(
            'Capitalizzazione stimata',
            _marketCapText(
              detail.marketCap,
            ),
          ),
          const Divider(height: 24),
          _groupTitle('Fondamentali'),
          _metricRow(
            'Crescita ricavi',
            _numberValue(
              detail.revenueGrowthPct,
              suffix: '%',
            ),
          ),
          _metricRow(
            'Margine netto',
            _numberValue(
              detail.netMarginPct,
              suffix: '%',
            ),
          ),
          _metricRow(
            'Margine free cash flow',
            _numberValue(
              detail.fcfMarginPct,
              suffix: '%',
            ),
          ),
          _metricRow(
            'Passività / attivi',
            _numberValue(
              detail.liabilitiesToAssets ==
                      null
                  ? null
                  : detail
                          .liabilitiesToAssets! *
                      100,
              suffix: '%',
            ),
          ),
          const Divider(height: 24),
          _groupTitle(
            'Evento rilevato',
          ),
          _metricRow(
            'Catalizzatore',
            detail.catalystLabel.isEmpty
                ? 'n/d'
                : detail.catalystLabel,
          ),
          if (detail
              .catalystExplanation
              .isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 8,
              ),
              child: Align(
                alignment:
                    Alignment.centerLeft,
                child: Text(
                  detail
                      .catalystExplanation,
                  style: TextStyle(
                    color: Colors
                        .grey.shade400,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          if (detail.fundamentalsError !=
                  null &&
              detail.fundamentalsError!
                  .isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 17,
                  color:
                      Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alcuni dati del provider '
                    'non erano disponibili. '
                    'Il motore ha utilizzato '
                    'i dati SEC disponibili '
                    'e ha ridotto '
                    'l’affidabilità.',
                    style: TextStyle(
                      color: Colors
                          .grey.shade400,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (detail
              .explanation
              .isNotEmpty) ...[
            const Divider(height: 24),
            _groupTitle(
              'Sintesi quantitativa',
            ),
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                detail.explanation,
                style: TextStyle(
                  color:
                      Colors.grey.shade400,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(
    String text,
    Color color,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(
              top: 6,
            ),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyText(
    String text,
  ) {
    return Text(
      text,
      style: TextStyle(
        color:
            Colors.grey.shade500,
        fontSize: 13,
      ),
    );
  }

  Widget _groupTitle(
    String title,
  ) {
    return Align(
      alignment:
          Alignment.centerLeft,
      child: Padding(
        padding:
            const EdgeInsets.only(
          top: 4,
          bottom: 7,
        ),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color:
                Colors.grey.shade500,
            fontSize: 10,
            fontWeight:
                FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _metricRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors
                    .grey.shade400,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _conclusion(
    TickerDetail detail,
  ) {
    final confidence =
        detail.confidenceScore ?? 0;

    final valuation =
        detail.valuationScore ?? 0;

    final opportunity =
        detail.opportunityScore ?? 0;

    if (confidence < 50) {
      return 'Movimento da approfondire: '
          'l’analisi è ancora incompleta.';
    }

    if (valuation < 50) {
      return 'Il prezzo è sceso, '
          'ma la valutazione può '
          'essere ancora elevata.';
    }

    if (opportunity >= 70) {
      return 'Il movimento presenta '
          'segnali interessanti con dati '
          'sufficientemente completi.';
    }

    if (opportunity >= 55) {
      return 'Il movimento merita '
          'monitoraggio, ma non offre '
          'ancora un segnale forte.';
    }

    return 'Il ribasso è visibile, '
        'ma i dati attuali non indicano '
        'un’anomalia prioritaria.';
  }

  Color _positiveScoreColor(
    double? value,
  ) {
    if (value == null) {
      return Colors.grey;
    }

    if (value >= 70) {
      return Colors.greenAccent;
    }

    if (value >= 50) {
      return Colors.amber;
    }

    return Colors.orangeAccent;
  }

  String _scoreText(
    double? value,
  ) {
    if (value == null) {
      return 'n/d';
    }

    return value.toStringAsFixed(0);
  }

  String _scoreValue(
    double? value,
  ) {
    if (value == null) {
      return 'n/d';
    }

    return '${value.toStringAsFixed(0)}/100';
  }

  String _numberValue(
    double? value, {
    String suffix = '',
  }) {
    if (value == null) {
      return 'n/d';
    }

    return '${value.toStringAsFixed(1)}$suffix';
  }

  String _priceText(
    double? value,
  ) {
    if (value == null) {
      return 'n/d';
    }

    return '\$${value.toStringAsFixed(2)}';
  }

  String _marketCapText(
    double? value,
  ) {
    if (value == null) {
      return 'n/d';
    }

    if (value >= 1000000000) {
      final billions =
          value / 1000000000;

      final decimals =
          billions >= 100 ? 0 : 1;

      return '\$${billions.toStringAsFixed(decimals)} mld';
    }

    if (value >= 1000000) {
      final millions =
          value / 1000000;

      return '\$${millions.toStringAsFixed(0)} mln';
    }

    return '\$${value.toStringAsFixed(0)}';
  }
}
