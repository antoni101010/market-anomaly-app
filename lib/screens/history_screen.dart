import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
  });

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends State<HistoryScreen> {
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
      final entries =
          await ApiClient.instance.getHistory(
        limit: 300,
      );

      if (!mounted) return;

      setState(() {
        _entries = entries;
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

  Future<void> _openDetail(
    HistoryEntry entry,
  ) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TickerDetailScreen(
            ticker: entry.ticker,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dettaglio non disponibile: $error',
          ),
        ),
      );
    }
  }

  String _formatTime(
    String isoDate,
  ) {
    try {
      final date =
          DateTime.parse(isoDate).toLocal();

      return DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storico analisi'),
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
        physics:
            const AlwaysScrollableScrollPhysics(),
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
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.cloud_off_outlined,
            title:
                'Impossibile caricare lo storico',
            subtitle: _error,
            actionLabel: 'Riprova',
            onAction: _load,
          ),
        ],
      );
    }

    if (_entries.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyState(
            icon: Icons.history,
            title: 'Nessuna analisi registrata',
            subtitle:
                'Lo storico si aggiorna automaticamente '
                'dopo ogni scansione valida.',
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
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        Text(
          '${_entries.length} analisi registrate',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ogni elemento conserva i punteggi rilevati '
          'nel momento della scansione.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        ..._entries.map(_historyCard),
      ],
    );
  }

  Widget _historyCard(
    HistoryEntry entry,
  ) {
    final opportunityColor =
        _opportunityColor(
      entry.opportunityScore,
    );

    final riskColor =
        _riskColor(
      entry.valueTrapRisk,
    );

    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: () => _openDetail(entry),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.ticker,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (entry.company != null &&
                            entry.company!.isNotEmpty)
                          Text(
                            entry.company!,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 3),
                        Text(
                          _formatTime(
                            entry.signalTime,
                          ),
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(entry.price),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _historyLabel(entry),
                        style: TextStyle(
                          color: opportunityColor,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _scoreBox(
                      'Anomalia',
                      entry.anomalyScore,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _scoreBox(
                      'Opportunità',
                      entry.opportunityScore,
                      opportunityColor,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _scoreBox(
                      'Value trap',
                      entry.valueTrapRisk,
                      riskColor,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _scoreBox(
                      'Qualità',
                      entry.qualityScore,
                      _qualityColor(
                        entry.qualityScore,
                      ),
                    ),
                  ),
                ],
              ),
              if (entry.recoveryPotential != null ||
                  entry.catalystRisk != null) ...[
                const SizedBox(height: 9),
                Row(
                  children: [
                    if (entry.recoveryPotential !=
                        null)
                      Expanded(
                        child: Text(
                          'Recupero stimato: '
                          '${entry.recoveryPotential!.toStringAsFixed(0)}/100',
                          style: TextStyle(
                            color:
                                Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (entry.catalystRisk != null)
                      Text(
                        'Rischio evento: '
                        '${entry.catalystRisk!.toStringAsFixed(0)}/100',
                        style: TextStyle(
                          color:
                              Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreBox(
    String label,
    double? value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.09,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value?.toStringAsFixed(0) ?? 'n/d',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _historyLabel(
    HistoryEntry entry,
  ) {
    final opportunity =
        entry.opportunityScore ?? 0;

    final valueTrap =
        entry.valueTrapRisk ?? 0;

    if (valueTrap >= 70) {
      return 'RISCHIO ELEVATO';
    }

    if (opportunity >= 70) {
      return 'DA APPROFONDIRE';
    }

    if (opportunity >= 55) {
      return 'DA MONITORARE';
    }

    return 'NON PRIORITARIO';
  }

  Color _opportunityColor(
    double? value,
  ) {
    if (value == null) {
      return Colors.grey;
    }

    if (value >= 70) {
      return Colors.greenAccent;
    }

    if (value >= 55) {
      return Colors.amber;
    }

    return Colors.grey;
  }

  Color _riskColor(
    double? value,
  ) {
    if (value == null) {
      return Colors.grey;
    }

    if (value >= 70) {
      return Colors.redAccent;
    }

    if (value >= 45) {
      return Colors.orangeAccent;
    }

    return Colors.greenAccent;
  }

  Color _qualityColor(
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

  String _formatPrice(
    double? value,
  ) {
    if (value == null) {
      return 'n/d';
    }

    return '\$${value.toStringAsFixed(2)}';
  }
}
