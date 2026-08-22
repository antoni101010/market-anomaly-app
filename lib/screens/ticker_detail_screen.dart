import 'package:flutter/material.dart';
import '../api_client.dart';
import '../models.dart';
import '../theme.dart';

class TickerDetailScreen extends StatefulWidget {
  final String ticker;
  const TickerDetailScreen({super.key, required this.ticker});

  @override
  State<TickerDetailScreen> createState() => _TickerDetailScreenState();
}

class _TickerDetailScreenState extends State<TickerDetailScreen> {
  TickerDetail? _detail;
  bool _loading = true;
  String? _error;
  bool _watchlistBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await ApiClient.instance.getTickerDetail(widget.ticker);
      setState(() => _detail = d);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleWatchlist() async {
    final d = _detail;
    if (d == null) return;
    setState(() => _watchlistBusy = true);
    try {
      if (d.inWatchlist) {
        await ApiClient.instance.removeFromWatchlist(d.ticker);
      } else {
        await ApiClient.instance.addToWatchlist(d.ticker);
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      setState(() => _watchlistBusy = false);
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
              icon: _watchlistBusy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      _detail!.inWatchlist ? Icons.star : Icons.star_border,
                      color: _detail!.inWatchlist ? Colors.amber : null,
                    ),
              onPressed: _watchlistBusy ? null : _toggleWatchlist,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Impossibile caricare i dati',
        subtitle: _error,
        actionLabel: 'Riprova',
        onAction: _load,
      );
    }
    final d = _detail;
    if (d == null) return const SizedBox.shrink();

    final color = classificationColor(d.narrative.classificationLabel);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(d.sectorEtf, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  d.lastClose != null ? '\$${d.lastClose!.toStringAsFixed(2)}' : '-',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (d.drawdown52wPct != null)
                  Text('${d.drawdown52wPct!.toStringAsFixed(1)}% da massimo 52w',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.narrative.classificationLabel,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text('${d.narrative.classificationScore.toStringAsFixed(0)}/100',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ScoreBadge(label: 'Anomaly', value: d.anomalyScore),
            ScoreBadge(label: 'Opportunity', value: d.opportunityScore, color: color),
            ScoreBadge(label: 'Recovery', value: d.recoveryPotential),
            ScoreBadge(label: 'Quality', value: d.qualityScore),
            ScoreBadge(label: 'Value Trap', value: d.valueTrapRisk),
            ScoreBadge(label: 'Catalyst Risk', value: d.catalystRisk),
          ],
        ),
        const SizedBox(height: 24),

        _sectionTitle('Perché potrebbe essere un\'anomalia', Icons.trending_down, Colors.greenAccent),
        ...d.narrative.whyAnomaly.map((r) => _bulletCard(r, Colors.greenAccent)),

        const SizedBox(height: 20),
        _sectionTitle('Perché potrebbe NON esserlo', Icons.warning_amber_outlined, Colors.orangeAccent),
        ...d.narrative.whyNot.map((r) => _bulletCard(r, Colors.orangeAccent)),

        const SizedBox(height: 20),
        _sectionTitle('Evento scatenante', Icons.bolt_outlined, Colors.blueAccent),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.catalystLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(d.catalystExplanation, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        _sectionTitle('Fondamentali', Icons.assessment_outlined, Colors.grey),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _fundamentalRow('Crescita ricavi', d.revenueGrowthPct, '%'),
                _fundamentalRow('Margine netto', d.netMarginPct, '%'),
                _fundamentalRow('Debito/Attivi', d.liabilitiesToAssets, ''),
                _fundamentalRow('Margine FCF', d.fcfMarginPct, '%'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        _sectionTitle('Spiegazione quantitativa', Icons.functions, Colors.grey),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(d.explanation, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'Analisi quantitativa a scopo di ricerca. Non costituisce consulenza finanziaria '
          'né raccomandazione di investimento.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _bulletCard(String text, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _fundamentalRow(String label, double? value, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          Text(
            value != null ? '${value.toStringAsFixed(1)}$suffix' : 'n/d',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
