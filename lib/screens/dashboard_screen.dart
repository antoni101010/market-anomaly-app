import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;

  const DashboardScreen({
    super.key,
    required this.onOpenSettings,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  DashboardData? _data;
  bool _loading = false;
  bool _scanning = false;
  String? _error;
  String _scanMessage = '';
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!ApiClient.instance.isConfigured) {
      if (mounted) {
        setState(() {
          _error = 'not_configured';
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
      final data =
          await ApiClient.instance.getDashboard();

      if (!mounted) return;

      setState(() {
        _data = data;
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

  Future<void> _runScan() async {
    if (_scanning) return;

    setState(() {
      _scanning = true;
      _scanMessage = 'Avvio scansione...';
    });

    try {
      final result = await ApiClient.instance
          .triggerScan(limit: 100);

      if (!mounted) return;

      if (result['ok'] != true) {
        setState(() {
          _scanMessage =
              result['message']?.toString() ??
                  'Scansione già in corso...';
        });
      } else {
        setState(() {
          _scanMessage =
              result['message']?.toString() ??
                  'Scansione in corso...';
        });
      }

      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _pollScanStatus(),
      );

      await _pollScanStatus();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _scanning = false;
        _scanMessage = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore avvio scansione: $error',
          ),
        ),
      );
    }
  }

  Future<void> _pollScanStatus() async {
    try {
      final status =
          await ApiClient.instance.getScanStatus();
      final scanStatus =
          status['status']?.toString() ?? 'idle';

      if (!mounted) return;

      if (scanStatus == 'running') {
        setState(() {
          _scanMessage =
              status['message']?.toString() ??
                  'Scansione in corso...';
        });
        return;
      }

      _pollTimer?.cancel();

      setState(() {
        _scanning = false;
        _scanMessage = '';
      });

      if (scanStatus == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Scansione fallita: '
              '${status['message'] ?? 'errore sconosciuto'}',
            ),
          ),
        );
        return;
      }

      if (scanStatus == 'done') {
        await _load();
      }
    } catch (_) {
      // Un errore temporaneo di rete non interrompe
      // il controllo. Il timer riproverà.
    }
  }

  String _formatScanTime(String? isoDate) {
    if (isoDate == null) {
      return 'mai eseguita';
    }

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
        title: const Text('Market Anomaly'),
        actions: [
          IconButton(
            tooltip: 'Impostazioni',
            icon: const Icon(
              Icons.settings_outlined,
            ),
            onPressed: widget.onOpenSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
      floatingActionButton:
          ApiClient.instance.isConfigured
              ? FloatingActionButton.extended(
                  onPressed:
                      _scanning ? null : _runScan,
                  icon: _scanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    _scanning
                        ? 'Scansione...'
                        : 'Aggiorna',
                  ),
                )
              : null,
    );
  }

  Widget _buildBody() {
    if (_error == 'not_configured') {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.dns_outlined,
            title: 'Configura il server',
            subtitle:
                'Apri le impostazioni e inserisci '
                'l’indirizzo del backend.',
            actionLabel: 'Apri impostazioni',
            onAction: widget.onOpenSettings,
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final data = _data;

    if (data == null) {
      return const SizedBox.shrink();
    }

    if (data.scanTime == null && !_scanning) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyState(
            icon: Icons.query_stats_outlined,
            title: 'Nessuna scansione disponibile',
            subtitle:
                'Tocca “Scansiona ora” per analizzare '
                'il mercato.',
            actionLabel: 'Scansiona ora',
            onAction: _runScan,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        96,
      ),
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        if (_scanning) _buildScanningBanner(),
        _buildScanHeader(data),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statTile(
                'Analizzati',
                data.stats.analyzed.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                'Risultati',
                data.stats.candidates.toString(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                'Migliore',
                data.stats.maxOpportunity
                        ?.toStringAsFixed(0) ??
                    'n/d',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Movimenti rilevati',
          style:
              Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Text(
          'Ordinati per punteggio di opportunità. '
          'Un forte ribasso non significa automaticamente '
          'che il titolo sia conveniente.',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        if (data.topAnomalies.isEmpty)
          const EmptyState(
            icon: Icons.search_off,
            title: 'Nessun movimento rilevato',
            subtitle:
                'Aggiorna i dati oppure attendi '
                'la prossima scansione.',
          )
        else
          ...data.topAnomalies
              .asMap()
              .entries
              .map(
                (entry) => _anomalyCard(
                  entry.key + 1,
                  entry.value,
                ),
              ),
      ],
    );
  }

  Widget _buildScanningBanner() {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _scanMessage.isEmpty
                  ? 'Scansione in corso sul server...'
                  : _scanMessage,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanHeader(
    DashboardData data,
  ) {
    final isDemo =
        data.marketMode == 'demo';

    final modeColor = isDemo
        ? Colors.orangeAccent
        : Colors.greenAccent;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Ultima scansione: '
            '${_formatScanTime(data.scanTime)}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: modeColor.withValues(
              alpha: 0.15,
            ),
            borderRadius:
                BorderRadius.circular(6),
          ),
          child: Text(
            isDemo ? 'DEMO' : 'LIVE',
            style: TextStyle(
              fontSize: 10,
              color: modeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _anomalyCard(
    int rank,
    AnomalyRow row,
  ) {
    final color =
        classificationColor(
      row.classification,
    );

    final note = _resultNote(row);

    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(14),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  TickerDetailScreen(
                ticker: row.ticker,
              ),
            ),
          );

          if (mounted) {
            _load();
          }
        },
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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        color.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: color,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                row.ticker,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (row.inWatchlist) ...[
                              const SizedBox(
                                width: 6,
                              ),
                              Icon(
                                Icons.star,
                                size: 15,
                                color: Colors
                                    .amber.shade400,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          row.company,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                Colors.grey.shade500,
                            fontSize: 12,
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
                        row.price == null
                            ? 'n/d'
                            : '\$${row.price!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (row.drawdown52wPct != null)
                        Text(
                          '${row.drawdown52wPct!.toStringAsFixed(1)}% '
                          'da max',
                          style:
                              const TextStyle(
                            color:
                                Colors.redAccent,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.classification,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      note,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _miniScore(
                      'Anomalia',
                      row.anomalyScore,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _miniScore(
                      'Valutazione',
                      row.valuationScore,
                      _valuationColor(
                        row.valuationScore,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _miniScore(
                      'Affidabilità',
                      row.confidenceScore,
                      _confidenceColor(
                        row.confidenceScore,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _miniScore(
                      'Opportunità',
                      row.opportunityScore,
                      color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniScore(
    String label,
    double? value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
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

  String _resultNote(
    AnomalyRow row,
  ) {
    final confidence =
        row.confidenceScore ?? 0;
    final valuation =
        row.valuationScore ?? 0;
    final opportunity =
        row.opportunityScore ?? 0;

    if (confidence < 50) {
      return 'Analisi incompleta: servono più dati '
          'prima di valutare il movimento.';
    }

    if (valuation < 50) {
      return 'Il titolo è sceso, ma può risultare '
          'ancora costoso.';
    }

    if (opportunity >= 70) {
      return 'Movimento anomalo con dati '
          'sufficientemente solidi.';
    }

    if (opportunity >= 55) {
      return 'Movimento da monitorare '
          'e approfondire.';
    }

    return 'Il movimento non risulta prioritario '
        'con i dati attuali.';
  }

  Color _valuationColor(
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

  Color _confidenceColor(
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
}
