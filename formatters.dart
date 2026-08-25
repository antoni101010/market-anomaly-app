import 'package:flutter/material.dart';

import '../api_client.dart';
import '../legal_service.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onSaved;
  final VoidCallback onLegalReset;

  const SettingsScreen({
    super.key,
    required this.onSaved,
    required this.onLegalReset,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  static const String _defaultBackendUrl =
      'https://market-anomaly-api-wd0z.onrender.com';

  final _urlController = TextEditingController();
  final _keyController = TextEditingController();

  bool _testing = false;
  bool _saving = false;
  bool _obscureKey = true;
  bool _testOk = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();

    _urlController.text =
        ApiClient.instance.baseUrl ??
            _defaultBackendUrl;
    _keyController.text =
        ApiClient.instance.apiKey ?? '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  String? _validate() {
    final url = _urlController.text.trim();
    final apiKey = _keyController.text.trim();

    if (url.isEmpty) {
      return 'Inserisci l’indirizzo del server.';
    }

    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return 'Inserisci un indirizzo valido che inizi '
          'con https://';
    }

    if (apiKey.isEmpty) {
      return 'Inserisci la chiave API dell’app.';
    }

    return null;
  }

  void _showValidationError(String message) {
    setState(() {
      _testOk = false;
      _testResult = message;
    });
  }

  Future<void> _testConnection() async {
    final validationError = _validate();

    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    setState(() {
      _testing = true;
      _testResult = null;
    });

    final previousUrl =
        ApiClient.instance.baseUrl ?? '';
    final previousKey =
        ApiClient.instance.apiKey ?? '';

    try {
      await ApiClient.instance.save(
        baseUrl: _urlController.text.trim(),
        apiKey: _keyController.text.trim(),
      );

      final health =
          await ApiClient.instance.health();

      await ApiClient.instance.getScanStatus();
      final learning = await ApiClient.instance.getLearningSummary();
      final diagnostics = await ApiClient.instance.getDiagnostics();

      if (!mounted) return;

      final dataMode =
          health['data_mode']?.toString() ??
              'non indicata';
      final provider =
          health['provider']?.toString();
      final snapshots = (learning['snapshots'] as num?)?.toInt() ?? 0;
      final outcomes = (learning['outcomes_completed'] as num?)?.toInt() ?? 0;
      final databaseOk = diagnostics['database_exists'] == true;
      final apiProtected = health['api_protected'] == true;
      final secConfigured = diagnostics['sec_user_agent_configured'] == true;

      setState(() {
        _testOk = true;
        _testResult = provider == null
            ? 'Connessione riuscita. Modalità: $dataMode.'
            : 'Connessione riuscita. Modalità: $dataMode, '
                'provider: $provider. Memoria: $snapshots snapshot, '
                '$outcomes esiti verificati; database '
                '${databaseOk ? 'attivo' : 'da verificare'}; sicurezza API '
                '${apiProtected ? 'attiva' : 'da configurare'}; identificazione '
                'SEC ${secConfigured ? 'attiva' : 'da configurare'}.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _testOk = false;
        _testResult = error.toString();
      });
    } finally {
      await ApiClient.instance.save(
        baseUrl: previousUrl,
        apiKey: previousKey,
      );

      if (mounted) {
        setState(() {
          _testing = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final validationError = _validate();

    if (validationError != null) {
      _showValidationError(validationError);
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ApiClient.instance.save(
        baseUrl: _urlController.text.trim(),
        apiKey: _keyController.text.trim(),
      );
      await LegalService.instance.syncAcceptanceBestEffort();

      if (!mounted) return;

      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impostazioni salvate.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _testOk = false;
        _testResult =
            'Impossibile salvare: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deleteInstallationData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminare i dati di installazione?'),
        content: const Text(
          'Verrà eliminato dal backend il record pseudonimo di accettazione '
          'e verrà reimpostata l’accettazione locale. Per continuare sarà '
          'necessario accettare nuovamente i Termini correnti.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await LegalService.instance.deleteInstallationData();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onLegalReset();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cancellazione non riuscita: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _testing || _saving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            32,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cloud_outlined,
                    color: Colors.lightBlueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'L’app usa il server centrale per eseguire '
                      'le analisi. Le chiavi dei provider finanziari '
                      'rimangono solamente sul server.',
                      style: TextStyle(
                        color: Colors.grey.shade300,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Indirizzo del backend',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'È già inserito l’indirizzo pubblico del server Render.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              enabled: !busy,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                hintText: 'https://server.onrender.com',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Chiave API dell’app',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Inserisci la stessa chiave configurata nella '
              'variabile MARKET_ANOMALY_API_KEY su Render.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _keyController,
              enabled: !busy,
              obscureText: _obscureKey,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: 'Chiave API',
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(
                  tooltip: _obscureKey
                      ? 'Mostra chiave'
                      : 'Nascondi chiave',
                  onPressed: () {
                    setState(() {
                      _obscureKey = !_obscureKey;
                    });
                  },
                  icon: Icon(
                    _obscureKey
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        busy ? null : _testConnection,
                    icon: _testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label: const Text('Testa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Salva'),
                  ),
                ),
              ],
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_testOk ? Colors.green : Colors.red)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_testOk ? Colors.green : Colors.red)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testOk
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 19,
                      color: _testOk
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          color: _testOk
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Legale, privacy e metodologia',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.policy_outlined),
                title: const Text('Documenti e metodologia'),
                subtitle: const Text(
                  'Termini, privacy, fonti, ritardi e conflitti d’interesse',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalHubScreen()),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Elimina dati di installazione'),
                subtitle: const Text(
                  'Cancella il record pseudonimo di accettazione dal backend',
                ),
                onTap: busy ? null : _deleteInstallationData,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'La chiave viene salvata localmente sul dispositivo. '
              'Non condividerla in schermate, messaggi o repository pubblici.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
