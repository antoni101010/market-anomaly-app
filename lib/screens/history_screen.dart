import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_client.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ApiClient.instance.isConfigured) {
      setState(() {
        _error = 'not_configured';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await ApiClient.instance.getHistory(limit: 300);
      setState(() => _entries = entries);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatTime(String iso) {
    try {
      return DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storico segnali')),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_error == 'not_configured') {
      return const EmptyState(
        icon: Icons.dns_outlined,
        title: 'Configura prima il server',
        subtitle: 'Vai in Impostazioni per collegare l\'app al backend.',
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Impossibile caricare lo storico',
            subtitle: _error,
            actionLabel: 'Riprova',
            onAction: _load,
          ),
        ],
      );
    }
    if (_entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyState(
            icon: Icons.history,
            title: 'Nessun segnale ancora registrato',
            subtitle: 'Lo storico si popola automaticamente ad ogni scansione valida.',
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _entries.length,
      itemBuilder: (context, i) {
        final e = _entries[i];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TickerDetailScreen(ticker: e.ticker))),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.ticker, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_formatTime(e.signalTime), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ),
                  ScoreBadge(label: 'Opportunity', value: e.opportunityScore),
                  const SizedBox(width: 8),
                  ScoreBadge(label: 'Anomaly', value: e.anomalyScore),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
