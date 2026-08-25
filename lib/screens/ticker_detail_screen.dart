import 'package:flutter/material.dart';

import '../api_client.dart';
import '../formatters.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/price_chart.dart';

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
  bool _feedbackBusy = false;
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
      final detail = await ApiClient.instance
          .getTickerDetail(widget.ticker);

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

    if (detail == null || _watchlistBusy) return;

    setState(() {
      _watchlistBusy = true;
    });

    try {
      if (detail.inWatchlist) {
        await ApiClient.instance
            .removeFromWatchlist(detail.ticker);
      } else {
        await ApiClient.instance
            .addToWatchlist(detail.ticker);
      }

      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _watchlistBusy = false;
        });
      }
    }
  }

  Future<void> _sendFeedback(String type) async {
    final detail = _detail;
    if (detail == null || _feedbackBusy) return;
    setState(() => _feedbackBusy = true);
    try {
      await ApiClient.instance.submitFeedback(detail.ticker, type);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback registrato nello storico del modello.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _feedbackBusy = false);
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
              tooltip: _detail!.inWatchlist
                  ? 'Rimuovi dalla watchlist'
                  : 'Aggiungi alla watchlist',
              onPressed:
                  _watchlistBusy ? null : _toggleWatchlist,
              icon: _watchlistBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _detail!.inWatchlist
                          ? Icons.star
                          : Icons.star_border,
                      color: _detail!.inWatchlist
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
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Impossibile caricare i dati',
        subtitle: _error,
        actionLabel: 'Riprova',
        onAction: _load,
      );
    }

    final detail = _detail;

    if (detail == null) {
      return const SizedBox.shrink();
    }

    final classification =
        detail.narrative.classificationLabel;
    final color = classificationColor(classification);
    final conclusion = _buildConclusion(detail);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          32,
        ),
        children: [
          _buildHeader(detail),
          const SizedBox(height: 16),
          PriceChartCard(ticker: detail.ticker),
          const SizedBox(height: 10),
          _buildConclusionCard(
            detail,
            conclusion,
            color,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ScoreBadge(
                  label: 'Anomalia',
                  value: detail.anomalyScore,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScoreBadge(
                  label: 'Valutazione',
                  value: detail.valuationScore,
                  color: _valuationColor(
                    detail.valuationScore,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ScoreBadge(
                  label: 'Affidabilità',
                  value: detail.confidenceScore,
                  color: _confidenceColor(
                    detail.confidenceScore,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle(
            'Perché è un movimento anomalo',
            Icons.trending_down,
            Colors.greenAccent,
          ),
          if (detail.narrative.whyAnomaly.isEmpty)
            _emptyExplanation('Nessun segnale rilevato.')
          else
            ...detail.narrative.whyAnomaly.map(
              (text) => _bulletCard(
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
          if (detail.narrative.whyNot.isEmpty)
            _emptyExplanation(
              'Nessuna criticità specifica rilevata.',
            )
          else
            ...detail.narrative.whyNot.map(
              (text) => _bulletCard(
                text,
                Colors.orangeAccent,
              ),
            ),
          const SizedBox(height: 20),
          _buildAdvancedSection(detail),
          const SizedBox(height: 14),
          _buildFeedbackCard(detail),
          const SizedBox(height: 24),
          Text(
            'Analisi statistica e di ricerca. Non costituisce consulenza '
            'finanziaria personalizzata, istruzione operativa o garanzia '
            'sui risultati futuri. Verifica sempre i dati autonomamente.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TickerDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.company,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail.sectorEtf.isEmpty
                        ? detail.ticker
                        : '${detail.ticker} · confronto ${detail.sectorEtf}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(detail.lastClose, detail.currency),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (detail.drawdown52wPct != null)
                  Text(
                    '${detail.drawdown52wPct!.toStringAsFixed(1)}% dal massimo 52 settimane',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Icon(
              detail.priceStatus == 'conflict' || detail.priceStatus == 'stale'
                  ? Icons.warning_amber_outlined
                  : Icons.schedule,
              size: 13,
              color: detail.priceStatus == 'conflict' || detail.priceStatus == 'stale'
                  ? Colors.orangeAccent
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '${priceStatusLabel(detail.priceStatus)} · '
                '${formatObservedAt(detail.priceObservedAt)} · '
                '${detail.priceSource}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 9),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConclusionCard(
    TickerDetail detail,
    String conclusion,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.narrative.classificationLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${detail.opportunityScore?.toStringAsFixed(0) ?? '-'}'
                '/100',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conclusion,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (detail.narrative.dataGaps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Dati da completare: ${detail.narrative.dataGaps.join('; ')}.',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedSection(TickerDetail detail) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 3,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          16,
        ),
        leading: const Icon(Icons.analytics_outlined),
        title: const Text(
          'Dati e rischi avanzati',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: const Text(
          'Valutazione, fondamentali e qualità dei dati',
          style: TextStyle(fontSize: 11),
        ),
        children: [
          _subsectionLabel('Punteggi'),
          _dataRow('Somiglianza con casi storici', detail.opportunityScore),
          _dataRow('Pattern di recupero storico', detail.recoveryPotential),
          _dataRow('Qualità fondamentale', detail.qualityScore),
          _dataRow('Rischio value trap', detail.valueTrapRisk),
          _dataRow('Rischio finanziario', detail.financialRiskScore),
          _dataRow('Rischio deterioramento', detail.distressRiskScore),
          _dataRow('Rischio diluizione', detail.dilutionRiskScore),
          _dataRow('Rischio catalizzatore', detail.catalystRisk),
          const Divider(height: 24),
          _subsectionLabel('Valutazione'),
          _dataRow(
            'P/E stimato',
            detail.peRatio,
            decimals: 1,
            suffix: 'x',
          ),
          _dataRow(
            'Prezzo / ricavi',
            detail.priceToSales,
            decimals: 1,
            suffix: 'x',
          ),
          _dataRow(
            'Rendimento free cash flow',
            detail.fcfYieldPct,
            decimals: 1,
            suffix: '%',
          ),
          _textRow(
            'Capitalizzazione stimata',
            formatCompactMoney(detail.marketCap, detail.currency),
          ),
          if (detail.currency.toUpperCase() != 'USD' &&
              detail.marketCapUsd != null)
            _textRow(
              'Capitalizzazione confrontabile',
              "${formatCompactMoney(detail.marketCapUsd, 'USD')} (cambio EOD)",
            ),
          const Divider(height: 24),
          _subsectionLabel('Fondamentali'),
          _dataRow(
            'Crescita ricavi',
            detail.revenueGrowthPct,
            decimals: 1,
            suffix: '%',
          ),
          _dataRow(
            'Margine netto',
            detail.netMarginPct,
            decimals: 1,
            suffix: '%',
          ),
          _dataRow(
            'Margine free cash flow',
            detail.fcfMarginPct,
            decimals: 1,
            suffix: '%',
          ),
          _dataRow(
            'Passività / attivi',
            detail.liabilitiesToAssets == null
                ? null
                : detail.liabilitiesToAssets! * 100,
            decimals: 1,
            suffix: '%',
          ),
          const Divider(height: 24),
          _subsectionLabel('Qualità e provenienza dati'),
          _textRow('Fonte prezzo', detail.priceSource),
          _textRow('Stato prezzo', priceStatusLabel(detail.priceStatus)),
          _textRow(
            'Osservato',
            formatObservedAt(detail.priceObservedAt),
          ),
          _textRow('Fonte fondamentali', detail.fundamentalsSource),
          if (detail.fundamentalsPeriodEnd != null)
            _textRow('Periodo fondamentali', detail.fundamentalsPeriodEnd!),
          _dataRow(
            'Completezza fondamentali',
            detail.dataCompletenessPct,
            decimals: 0,
            suffix: '%',
          ),
          _textRow('Versione modello', detail.modelVersion),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Prezzi e fondamentali possono essere EOD o ritardati in base '
                'al mercato e al provider. I campi mancanti riducono '
                'l’affidabilità dell’analisi.',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const Divider(height: 24),
          _subsectionLabel('Evento rilevato'),
          _textRow('Catalizzatore', detail.catalystLabel),
          if (detail.catalystExplanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  detail.catalystExplanation,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          if (detail.narrative.dataGaps.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dati mancanti o da verificare: '
                    '${detail.narrative.dataGaps.join('; ')}.',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (detail.explanation.isNotEmpty) ...[
            const Divider(height: 24),
            _subsectionLabel('Sintesi quantitativa'),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                detail.explanation,
                style: TextStyle(
                  color: Colors.grey.shade400,
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

  String _buildConclusion(TickerDetail detail) {
    if (detail.narrative.summary.trim().isNotEmpty) {
      return detail.narrative.summary;
    }
    return 'Sintesi non disponibile per questo snapshot.';
  }

  Color _valuationColor(double? value) {
    if (value == null) return Colors.grey;
    if (value >= 70) return Colors.greenAccent;
    if (value >= 50) return Colors.amber;
    return Colors.orangeAccent;
  }

  Color _confidenceColor(double? value) {
    if (value == null) return Colors.grey;
    if (value >= 70) return Colors.greenAccent;
    if (value >= 50) return Colors.amber;
    return Colors.orangeAccent;
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletCard(
    String text,
    Color dotColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
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

  Widget _emptyExplanation(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 13,
      ),
    );
  }

  Widget _subsectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 7,
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _dataRow(
    String label,
    double? value, {
    int decimals = 0,
    String suffix = '/100',
  }) {
    final formatted = value == null
        ? 'n/d'
        : '${value.toStringAsFixed(decimals)}$suffix';

    return _textRow(label, formatted);
  }

  Widget _textRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(TickerDetail detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aiuta il controllo del modello',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              'Il feedback viene salvato insieme allo snapshot; non modifica automaticamente i pesi in produzione.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, height: 1.35),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _feedbackBusy ? null : () => _sendFeedback('useful'),
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 17),
                    label: const Text('Utile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _feedbackBusy
                        ? null
                        : () => _sendFeedback('possible_false_signal'),
                    icon: const Icon(Icons.flag_outlined, size: 17),
                    label: const Text('Possibile errore'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
