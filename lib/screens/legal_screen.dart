import 'package:flutter/material.dart';

import '../legal_content.dart';
import '../legal_service.dart';

class LegalAcceptanceScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const LegalAcceptanceScreen({super.key, required this.onAccepted});

  @override
  State<LegalAcceptanceScreen> createState() => _LegalAcceptanceScreenState();
}

class _LegalAcceptanceScreenState extends State<LegalAcceptanceScreen> {
  bool _terms = false;
  bool _privacySeen = false;
  bool _saving = false;

  Future<void> _accept() async {
    if (!_terms || !_privacySeen || _saving) return;
    setState(() => _saving = true);
    await LegalService.instance.acceptCurrent();
    if (!mounted) return;
    widget.onAccepted();
  }

  Future<void> _open(String title, String text) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(title: title, text: text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prima di iniziare')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const Icon(Icons.query_stats, size: 44),
            const SizedBox(height: 14),
            Text(
              'Market Anomaly è ricerca statistica',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              LegalContent.shortFinancialNotice,
              style: TextStyle(height: 1.45),
            ),
            const SizedBox(height: 18),
            _documentTile(
              'Termini e condizioni',
              'Versione ${LegalContent.termsVersion}',
              () => _open('Termini e condizioni', LegalContent.terms),
            ),
            _documentTile(
              'Informativa privacy',
              'Versione ${LegalContent.privacyVersion}',
              () => _open('Informativa privacy', LegalContent.privacy),
            ),
            _documentTile(
              'Metodologia e limiti',
              'Come vengono costruiti i punteggi',
              () => _open('Metodologia e limiti', LegalContent.methodology),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _terms,
              onChanged: (value) => setState(() => _terms = value == true),
              title: const Text('Accetto i Termini e condizioni d’uso.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _privacySeen,
              onChanged: (value) =>
                  setState(() => _privacySeen = value == true),
              title: const Text(
                'Confermo di aver ricevuto e letto l’Informativa privacy.',
              ),
              subtitle: const Text(
                'Questa conferma non è un consenso marketing o pubblicitario.',
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _terms && _privacySeen && !_saving ? _accept : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Accetta e continua'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class LegalHubScreen extends StatelessWidget {
  const LegalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final acceptedAt = LegalService.instance.acceptedAt;
    return Scaffold(
      appBar: AppBar(title: const Text('Legale e metodologia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (acceptedAt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Termini correnti accettati: $acceptedAt',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ),
          _tile(context, 'Termini e condizioni', LegalContent.terms),
          _tile(context, 'Informativa privacy', LegalContent.privacy),
          _tile(context, 'Metodologia, fonti e ritardi', LegalContent.methodology),
          _tile(context, 'Conflitti d’interesse', LegalContent.conflicts),
          _tile(context, 'Riferimenti normativi', LegalContent.regulatorySources),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              LegalContent.shortFinancialNotice,
              style: TextStyle(fontSize: 12, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String title, String text) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LegalDocumentScreen(title: title, text: text),
          ),
        ),
      ),
    );
  }
}

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String text;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [
            Text(
              text.trim(),
              style: const TextStyle(fontSize: 13, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}
