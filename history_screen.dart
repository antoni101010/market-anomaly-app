import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api_client.dart';
import '../formatters.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() =>
      _WatchlistScreenState();
}

class _WatchlistScreenState
    extends State<WatchlistScreen> {
  List<WatchlistItem> _items = [];
  final Set<String> _removing = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!ApiClient.instance.isConfigured) {
      if (mounted) {
        setState(() {
          _error = 'not_configured';
          _loading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final items =
          await ApiClient.instance.getWatchlist();

      if (!mounted) return;

      setState(() {
        _items = items;
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

  Future<void> _remove(WatchlistItem item) async {
    if (_removing.contains(item.ticker)) return;

    setState(() {
      _removing.add(item.ticker);
    });

    try {
      await ApiClient.instance
          .removeFromWatchlist(item.ticker);

      if (!mounted) return;

      setState(() {
        _items.removeWhere(
          (current) => current.ticker == item.ticker,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.ticker} rimosso dalla watchlist.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossibile rimuovere ${item.ticker}: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _removing.remove(item.ticker);
        });
      }
    }
  }

  Future<void> _openDetail(WatchlistItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TickerDetailScreen(
          ticker: item.ticker,
        ),
      ),
    );

    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error == 'not_configured') {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyState(
            icon: Icons.dns_outlined,
            title: 'Configura prima il server',
            subtitle:
                'Apri le impostazioni per collegare '
                'l’app al backend.',
          ),
        ],
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
            title: 'Watchlist vuota',
            subtitle:
                'Apri la scheda di un titolo e tocca '
                'la stella per seguirne l’evoluzione.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        28,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text(
          '${_items.length} '
          '${_items.length == 1 ? 'titolo seguito' : 'titoli seguiti'}',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Confronta il prezzo e i punteggi attuali '
          'con quelli registrati quando hai aggiunto il titolo.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        ..._items.map(_watchlistCard),
      ],
    );
  }

  Widget _watchlistCard(WatchlistItem item) {
    final performance = item.performancePct;
    final performanceColor = performance == null
        ? Colors.grey
        : performance >= 0
            ? Colors.greenAccent
            : Colors.redAccent;
    final isRemoving = _removing.contains(item.ticker);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isRemoving
            ? null
            : () => _openDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.ticker,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (item.company != null &&
                            item.company!.isNotEmpty)
                          Text(
                            item.company!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(item.currentPrice, item.currency),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatPerformance(performance),
                        style: TextStyle(
                          color: performanceColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Rimuovi dalla watchlist',
                    visualDensity: VisualDensity.compact,
                    onPressed: isRemoving
                        ? null
                        : () => _remove(item),
                    icon: isRemoving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _comparisonBox(
                      'Prezzo',
                      _formatPrice(item.priceAtAdd, item.currency),
                      _formatPrice(item.currentPrice, item.currency),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _comparisonBox(
                      'Somiglianza',
                      _formatScore(
                        item.opportunityScoreAtAdd,
                      ),
                      _formatScore(
                        item.opportunityScoreNow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _comparisonBox(
                      'Anomalia',
                      _formatScore(
                        item.anomalyScoreAtAdd,
                      ),
                      _formatScore(
                        item.anomalyScoreNow,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.catalystLabelNow.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: (item.hasNewEvent
                            ? Colors.orangeAccent
                            : Colors.white)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.hasNewEvent ? 'Nuovo evento: ' : 'Evento corrente: '}'
                    '${item.catalystLabelNow}',
                    style: TextStyle(
                      color: item.hasNewEvent
                          ? Colors.orangeAccent
                          : Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              if (item.addedAt != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Aggiunto il ${_formatDate(item.addedAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _comparisonBox(
    String label,
    String initialValue,
    String currentValue,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$initialValue → $currentValue',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double? value, String currency) {
    return formatMoney(value, currency);
  }

  String _formatScore(double? value) {
    if (value == null) return 'n/d';
    return value.toStringAsFixed(0);
  }

  String _formatPerformance(double? value) {
    if (value == null) return 'n/d';
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'n/d';

    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
