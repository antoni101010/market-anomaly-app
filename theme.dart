import 'package:flutter/material.dart';

import '../analysis_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  final AnalysisPreferences initial;

  const PreferencesScreen({
    super.key,
    required this.initial,
  });

  @override
  State<PreferencesScreen> createState() =>
      _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late AnalysisPreferences _preferences;
  bool _saving = false;
  Map<String, AnalysisPreferences> _presets = {};

  static const _sectorOptions = [
    'Technology',
    'Healthcare',
    'Financial Services',
    'Consumer Cyclical',
    'Consumer Defensive',
    'Communication Services',
    'Industrials',
    'Energy',
    'Basic Materials',
    'Real Estate',
    'Utilities',
  ];

  @override
  void initState() {
    super.initState();
    _preferences = widget.initial;
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await AnalysisPreferences.loadPresets();
    if (mounted) setState(() => _presets = presets);
  }

  Future<void> _savePreset() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salva configurazione'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Es. Europa restrittivo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _preferences.savePreset(name);
    await _loadPresets();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    await _preferences.save();

    if (!mounted) return;

    Navigator.of(context).pop(_preferences);
  }

  void _reset() {
    setState(() {
      _preferences = const AnalysisPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizza analisi'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _reset,
            child: const Text('Ripristina'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _infoCard(),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Modalità semplice'),
            subtitle: const Text(
              'Mostra scelte immediate e nasconde soglie tecniche e '
              'controlli del Deep Engine.',
            ),
            value: _preferences.simpleMode,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(simpleMode: value);
              });
            },
          ),
          const Divider(height: 28),
          _sectionTitle('Universo e filtri'),
          _dropdown(
            title: 'Mercati',
            value: _preferences.market,
            items: const {
              'global': 'Globale',
              'usa': 'Stati Uniti',
              'europe': 'Europa',
              'asia': 'Asia',
              'canada': 'Canada',
              'australia': 'Australia',
              'africa': 'Sudafrica',
            },
            onChanged: (value) => setState(
              () => _preferences = _preferences.copyWith(market: value),
            ),
          ),
          _dropdown(
            title: 'Dimensione aziende',
            value: _preferences.companySize,
            items: const {
              'all': 'Tutte',
              'large': 'Grandi (oltre 10 mld)',
              'medium': 'Medie (2–10 mld)',
              'small': 'Piccole (sotto 2 mld)',
            },
            onChanged: (value) => setState(
              () => _preferences = _preferences.copyWith(companySize: value),
            ),
          ),
          _dropdown(
            title: 'Ampiezza del filtro',
            value: _preferences.riskProfile,
            items: const {
              'conservative': 'Restrittivo',
              'balanced': 'Standard',
              'aggressive': 'Ampio',
            },
            onChanged: (value) => setState(
              () => _preferences = _preferences.copyWith(riskProfile: value),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Settori (nessuna selezione = tutti)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            children: _sectorOptions.map((sector) {
              final selected = _preferences.sectors.contains(sector);
              return FilterChip(
                label: Text(sector, style: const TextStyle(fontSize: 10)),
                selected: selected,
                onSelected: (enabled) {
                  final sectors = [..._preferences.sectors];
                  enabled ? sectors.add(sector) : sectors.remove(sector);
                  setState(() {
                    _preferences = _preferences.copyWith(sectors: sectors);
                  });
                },
              );
            }).toList(),
          ),
          const Divider(height: 28),
          if (_preferences.simpleMode) ...[
            _sectionTitle('Intensità del movimento'),
            _dropdown(
              title: 'Anomalia desiderata',
              value: _simpleAnomalyLevel(_preferences.minAnomaly, _preferences.maxAnomaly),
              items: const {
                'normal': 'Normale',
                'strong': 'Forte',
                'very_strong': 'Molto forte',
              },
              onChanged: (value) {
                final range = switch (value) {
                  'very_strong' => (60.0, 100.0),
                  'strong' => (40.0, 59.999),
                  _ => (20.0, 39.999),
                };
                setState(() {
                  _preferences = _preferences.copyWith(
                    minAnomaly: range.$1,
                    maxAnomaly: range.$2,
                  );
                });
              },
            ),
          ] else ...[
            _sectionTitle('Soglie quantitative'),
            _slider(
              title: 'Somiglianza storica minima',
              value: _preferences.minOpportunity,
              description: 'Nasconde i risultati con minore somiglianza ai casi storici del dataset.',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    minOpportunity: value,
                  );
                });
              },
            ),
            _slider(
              title: 'Anomalia minima',
              value: _preferences.minAnomaly,
              description: 'Richiede un movimento quantitativo più insolito.',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    minAnomaly: value,
                  );
                });
              },
            ),
            _slider(
              title: 'Affidabilità minima',
              value: _preferences.minConfidence,
              description: 'Esclude le analisi con troppi dati mancanti.',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    minConfidence: value,
                  );
                });
              },
            ),
            _slider(
              title: 'Rischio value trap massimo',
              value: _preferences.maxValueTrap,
              description:
                  'Esclude i titoli con rischio strutturale superiore.',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    maxValueTrap: value,
                  );
                });
              },
            ),
            const Divider(height: 28),
            _sectionTitle('Filtri avanzati'),
            const SizedBox(height: 12),
            _slider(
              title: 'Valutazione minima',
              value: _preferences.minValuation,
              description:
                  'Se maggiore di zero, richiede multipli disponibili e '
                  'una valutazione almeno pari alla soglia.',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    minValuation: value,
                  );
                });
              },
            ),
            _slider(
              title: 'Ribasso minimo dal massimo',
              value: _preferences.minDrawdownPct,
              description:
                  'Mostra soltanto movimenti scesi almeno di questa '
                  'percentuale dal massimo a 52 settimane.',
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    minDrawdownPct: value,
                  );
                });
              },
            ),
            _stepper(
              title: 'Volume medio minimo',
              value: _preferences.minAverageVolume,
              minimum: 0,
              maximum: 5000000,
              step: 100000,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    minAverageVolume: value,
                  );
                });
              },
            ),
            _dropdown(
              title: 'Tipo di evento',
              value: _preferences.eventFilter,
              items: const {
                'all': 'Tutti',
                'identified': 'Evento identificato',
                'earnings': 'Risultati o guidance',
                'structural': 'Possibile rischio strutturale',
              },
              onChanged: (value) => setState(
                () => _preferences = _preferences.copyWith(
                  eventFilter: value,
                ),
              ),
            ),
          ],
          const Divider(height: 28),
          _stepper(
            title: 'Risultati mostrati',
            value: _preferences.topN,
            minimum: 5,
            maximum: 100,
            step: 5,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(topN: value);
              });
            },
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(child: _sectionTitle('Configurazioni salvate')),
              TextButton.icon(
                onPressed: _savePreset,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Salva'),
              ),
            ],
          ),
          if (_presets.isEmpty)
            Text(
              'Nessuna configurazione salvata.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            )
          else
            ..._presets.entries.map(
              (entry) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key),
                subtitle: Text(
                  '${entry.value.market} · ${entry.value.riskProfile} · '
                  '${entry.value.sectors.isEmpty ? 'tutti i settori' : '${entry.value.sectors.length} settori'}',
                ),
                onTap: () => setState(() => _preferences = entry.value),
                trailing: IconButton(
                  tooltip: 'Elimina',
                  onPressed: () async {
                    await AnalysisPreferences.deletePreset(entry.key);
                    await _loadPresets();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          if (!_preferences.simpleMode) ...[
            _stepper(
              title: 'Titoli per scansione approfondita',
              value: _preferences.scanLimit,
              minimum: 10,
              maximum: 300,
              step: 25,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(scanLimit: value);
                });
              },
            ),
            _stepper(
              title: 'Catalizzatori approfonditi',
              value: _preferences.catalystTopN,
              minimum: 1,
              maximum: 120,
              step: 10,
              onChanged: (value) {
                setState(() {
                  _preferences = _preferences.copyWith(
                    catalystTopN: value,
                  );
                });
              },
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Icon(Icons.check),
          label: const Text('Salva personalizzazioni'),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Questi filtri cambiano solamente ciò che viene mostrato. '
        'I filtri modificano soltanto la ricerca mostrata e non costituiscono istruzioni operative o raccomandazioni personali.',
        style: TextStyle(fontSize: 12, height: 1.4),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    );
  }

  Widget _dropdown({
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DropdownButtonFormField<String>(
        key: ValueKey('$title-$value'),
        initialValue: items.containsKey(value) ? value : items.keys.first,
        decoration: InputDecoration(labelText: title),
        items: items.entries
            .map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }

  Widget _slider({
    required String title,
    required double value,
    required String description,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0.0, 100.0).toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepper({
    required String title,
    required int value,
    required int minimum,
    required int maximum,
    required int step,
    required ValueChanged<int> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value <= minimum
                ? null
                : () => onChanged(value - step),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 48,
            child: Text(
              _formatStepperValue(value),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: value >= maximum
                ? null
                : () => onChanged(value + step),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  String _simpleAnomalyLevel(double minimum, double maximum) {
    if (minimum >= 60 && maximum >= 99) return 'very_strong';
    if (minimum >= 40 && maximum < 60) return 'strong';
    return 'normal';
  }

  String _formatStepperValue(int value) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      return '${millions.toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return '$value';
  }
}
