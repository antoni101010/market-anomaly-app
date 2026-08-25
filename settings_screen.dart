import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api_client.dart';
import '../formatters.dart';
import '../models.dart';

class PriceChartCard extends StatefulWidget {
  final String ticker;
  final String? providerTicker;

  const PriceChartCard({
    super.key,
    required this.ticker,
    this.providerTicker,
  });

  @override
  State<PriceChartCard> createState() => _PriceChartCardState();
}

class _PriceChartCardState extends State<PriceChartCard> {
  static const periods = ['1G', '5G', '1M', '6M', '1A', '5A'];

  String _period = '1M';
  PriceHistoryData? _history;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load('1M');
  }

  Future<void> _load(String period) async {
    setState(() {
      _period = period;
      _loading = true;
      _error = null;
    });

    try {
      final history = await ApiClient.instance.getPriceHistory(
        widget.providerTicker ?? widget.ticker,
        period: period,
      );

      if (!mounted) return;

      setState(() => _history = history);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = _history;
    final change = history?.summary.changePct;
    final chartColor = change != null && change < 0
        ? Colors.redAccent
        : Colors.greenAccent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Andamento del prezzo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (change != null)
                  Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: chartColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _periodSelector(),
            const SizedBox(height: 14),
            SizedBox(
              height: 190,
              width: double.infinity,
              child: _chartBody(history, chartColor),
            ),
            if (!_loading && _error == null && history != null) ...[
              if (history.points.length >= 2) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _dateLabel(history.points.first.time),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      _dateLabel(history.points.last.time),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _summaryValue(
                      'Minimo',
                      _price(history.summary.periodLow, history.currency),
                    ),
                  ),
                  Expanded(
                    child: _summaryValue(
                      'Massimo',
                      _price(history.summary.periodHigh, history.currency),
                    ),
                  ),
                  Expanded(
                    child: _summaryValue(
                      'Max ribasso',
                      _percent(history.summary.maxDrawdownPct),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Quota mostrata: ${_price(history.summary.currentPrice, history.currency)} · '
                '${priceStatusLabel(history.summary.currentPriceStatus ?? 'unknown')} · '
                '${formatObservedAt(history.summary.currentPriceObservedAt)} · '
                '${dataSourceLabel(history.summary.currentPriceSource ?? 'unknown')}. '
                'Grafico: serie storica rettificata dal provider per le corporate action.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 9,
                  height: 1.35,
                ),
              ),
            ],
            if (history?.note != null) ...[
              const SizedBox(height: 10),
              Text(
                history!.note!,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _periodSelector() {
    return Row(
      children: periods.map((period) {
        final selected = period == _period;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: _loading ? null : () => _load(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _chartBody(PriceHistoryData? history, Color color) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
            TextButton(
              onPressed: () => _load(_period),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    if (history == null || history.points.length < 2) {
      return const Center(
        child: Text('Dati insufficienti per il grafico.'),
      );
    }

    return CustomPaint(
      painter: _PriceChartPainter(
        points: history.points,
        color: color,
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _summaryValue(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  String _price(double? value, String currency) {
    return formatMoney(value, currency);
  }

  String _percent(double? value) {
    return value == null ? 'n/d' : '${value.toStringAsFixed(1)}%';
  }

  String _dateLabel(DateTime value) {
    if (_period == '1G' || _period == '5G') {
      return DateFormat('dd/MM HH:mm').format(value.toLocal());
    }

    return DateFormat('dd/MM/yyyy').format(value.toLocal());
  }
}

class _PriceChartPainter extends CustomPainter {
  final List<PricePoint> points;
  final Color color;

  _PriceChartPainter({
    required this.points,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final closes = points.map((point) => point.close).toList();
    final minimum = closes.reduce(math.min);
    final maximum = closes.reduce(math.max);
    final span = math.max(maximum - minimum, maximum.abs() * 0.01);
    const horizontalPadding = 4.0;
    const verticalPadding = 10.0;
    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - verticalPadding * 2;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    for (var index = 0; index <= 4; index++) {
      final y = verticalPadding + chartHeight * index / 4;
      canvas.drawLine(
        Offset(horizontalPadding, y),
        Offset(size.width - horizontalPadding, y),
        gridPaint,
      );
    }

    final path = Path();

    for (var index = 0; index < closes.length; index++) {
      final x = horizontalPadding +
          chartWidth * index / math.max(1, closes.length - 1);
      final normalized = (closes[index] - minimum) / span;
      final y = verticalPadding + chartHeight * (1 - normalized);

      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width - horizontalPadding, size.height - verticalPadding)
      ..lineTo(horizontalPadding, size.height - verticalPadding)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.01),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PriceChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
