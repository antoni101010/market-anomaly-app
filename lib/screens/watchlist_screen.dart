import 'package:flutter/material.dart';
import '../api_client.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<WatchlistItem> _items = [];
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
      final items = await ApiClient.instance.getWatchlist();
      setState(() => _items = items);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
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
            title: 'Impossibile caricare la watchlist',
            subtitle: _error,
            actionLabel: 'Riprova',
            onAction: _load,
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyState(
            icon: Icons.star_border,
            title: 'Nessun titolo in watchlist',
            subtitle: 'Aggiungi titoli dalla scheda di dettaglio toccando la stella.',
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        final perf = item.performancePct;
        final perfColor = perf == null
            ? Colors.grey
            : (perf >= 0 ? Colors.greenAccent : Colors.redAccent);
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TickerDetailScreen(ticker: item.ticker)))
                .then((_) => _load()),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.ticker, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(item.company ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          'Aggiunto a \$${item.priceAtAdd?.toStringAsFixed(2) ?? '-'}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        perf != null ? '${perf >= 0 ? '+' : ''}${perf.toStringAsFixed(1)}%' : '-',
                        style: TextStyle(color: perfColor, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score ${item.opportunityScoreAtAdd?.toStringAsFixed(0) ?? '-'} → '
                        '${item.opportunityScoreNow?.toStringAsFixed(0) ?? '-'}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
