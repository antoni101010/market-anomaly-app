import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_client.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;
  const DashboardScreen({super.key, required this.onOpenSettings});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? _data;
  bool _loading = false;
  bool _scanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ApiClient.instance.isConfigured) {
      setState(() => _error = 'not_configured');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await ApiClient.instance.getDashboard();
      setState(() => _data = d);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runScan() async {
    setState(() => _scanning = true);
    try {
      await ApiClient.instance.triggerScan(limit: 100);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore scansione: $e')));
      }
    } finally {
      setState(() => _scanning = false);
    }
  }

  String _formatScanTime(String? iso) {
    if (iso == null) return 'mai eseguita';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd/MM HH:mm').format(dt);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Anomaly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: widget.onOpenSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
      floatingActionButton: ApiClient.instance.isConfigured
          ? FloatingActionButton.extended(
              onPressed: _scanning ? null : _runScan,
              icon: _scanning
                  ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.refresh),
              label: Text(_scanning ? 'Scansiono...' : 'Aggiorna'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_error == 'not_configured') {
      return EmptyState(
        icon: Icons.dns_outlined,
        title: 'Configura il server',
        subtitle: 'Vai in Impostazioni e inserisci l\'indirizzo del tuo backend per iniziare.',
        actionLabel: 'Vai alle Impostazioni',
        onAction: widget.onOpenSettings,
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Impossibile caricare i dati',
            subtitle: _error,
            actionLabel: 'Riprova',
            onAction: _load,
          ),
        ],
      );
    }
    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final data = _data;
    if (data == null) return const SizedBox.shrink();

    if (data.scanTime == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.query_stats_outlined,
            title: 'Nessuna scansione ancora eseguita',
            subtitle: 'Tocca "Aggiorna" per analizzare il mercato.',
            actionLabel: _scanning ? null : 'Scansiona ora',
            onAction: _scanning ? null : _runScan,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ultima scansione: ${_formatScanTime(data.scanTime)}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                data.marketMode == 'demo' ? 'DEMO' : 'LIVE',
                style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statTile('Analizzati', data.stats.analyzed.toString())),
            const SizedBox(width: 10),
            Expanded(child: _statTile('Candidati', data.stats.candidates.toString())),
            const SizedBox(width: 10),
            Expanded(
                child: _statTile(
                    'Opportunity max', data.stats.maxOpportunity?.toStringAsFixed(0) ?? '-')),
          ],
        ),
        const SizedBox(height: 20),
        Text('Top anomalie', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (data.topAnomalies.isEmpty)
          EmptyState(
            icon: Icons.search_off,
            title: 'Nessun candidato con i filtri attuali',
            subtitle: 'Prova ad aggiornare i dati o attendi la prossima scansione.',
          )
        else
          ...data.topAnomalies.asMap().entries.map((e) => _anomalyCard(e.key + 1, e.value)),
      ],
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _anomalyCard(int rank, AnomalyRow row) {
    final color = classificationColor(row.classification);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TickerDetailScreen(ticker: row.ticker)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text('$rank', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(row.ticker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        if (row.inWatchlist) Icon(Icons.star, size: 14, color: Colors.amber.shade400),
                      ],
                    ),
                    Text(row.company, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      row.classification,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ScoreBadge(label: 'Opp.', value: row.opportunityScore, color: color),
                  const SizedBox(height: 4),
                  Text(
                    row.drawdown52wPct != null ? '${row.drawdown52wPct!.toStringAsFixed(1)}%' : '-',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
