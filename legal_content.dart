import 'dart:async';

import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models.dart';
import '../theme.dart';
import 'ticker_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<SearchTickerResult> _results = [];
  bool _searching = false;
  String? _analyzingTicker;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _searching = false;
      });
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _search(value),
    );
  }

  Future<void> _search(String query) async {
    setState(() {
      _searching = true;
      _error = null;
    });

    try {
      final results = await ApiClient.instance.searchTickers(query);

      if (!mounted || query.trim() != _controller.text.trim()) return;

      setState(() => _results = results);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _analyze(SearchTickerResult result) async {
    if (_analyzingTicker != null) return;

    setState(() {
      _analyzingTicker = result.providerTicker;
      _error = null;
    });

    try {
      final detail = await ApiClient.instance.analyzeTicker(result);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TickerDetailScreen(
            ticker: detail.ticker,
            providerTicker: detail.providerTicker,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _analyzingTicker = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cerca titolo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              onChanged: _onQueryChanged,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Azienda o ticker, per esempio META',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _controller.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _controller.clear();
                              _onQueryChanged('');
                            },
                            icon: const Icon(Icons.close),
                          ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Puoi analizzare manualmente anche un titolo non presente '
              'nella scansione principale.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_controller.text.trim().isEmpty) {
      return const EmptyState(
        icon: Icons.manage_search,
        title: 'Cerca qualsiasi titolo',
        subtitle: 'Scrivi il ticker o il nome dell’azienda.',
      );
    }

    if (_searching && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty && _error == null) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Nessun risultato',
        subtitle: 'Controlla il ticker e riprova.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        final analyzing = _analyzingTicker == result.providerTicker;

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            title: Text(
              result.ticker,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${result.company}'
              '${result.providerTicker.isEmpty ? '' : ' · ${result.providerTicker}'}'
              '${result.currency.isEmpty ? '' : ' · ${result.currency}'}'
              '${result.isPrimary ? ' · quotazione principale' : ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: analyzing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _analyzingTicker == null
                ? () => _analyze(result)
                : null,
          ),
        );
      },
    );
  }
}
