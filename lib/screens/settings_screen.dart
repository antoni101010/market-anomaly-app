import 'package:flutter/material.dart';
import '../api_client.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onSaved;
  const SettingsScreen({super.key, required this.onSaved});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiClient.instance.baseUrl ?? '';
    _keyController.text = ApiClient.instance.apiKey ?? '';
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    // Salva temporaneamente per poter testare con i valori appena inseriti.
    await ApiClient.instance.save(baseUrl: _urlController.text.trim(), apiKey: _keyController.text.trim());
    try {
      final health = await ApiClient.instance.health();
      setState(() {
        _testOk = true;
        _testResult = 'Connesso — modalità dati: ${health['data_mode'] ?? '?'}';
      });
    } catch (e) {
      setState(() {
        _testOk = false;
        _testResult = e.toString();
      });
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    await ApiClient.instance.save(baseUrl: _urlController.text.trim(), apiKey: _keyController.text.trim());
    widget.onSaved();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impostazioni salvate.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Indirizzo del backend',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'L\'URL pubblico del tuo server (es. Render/Railway), senza slash finale.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'https://tuo-progetto.onrender.com',
              prefixIcon: Icon(Icons.dns_outlined),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Chiave API', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'La stessa impostata come MARKET_ANOMALY_API_KEY sul server.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _keyController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Chiave API',
              prefixIcon: Icon(Icons.key_outlined),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _testing ? null : _testConnection,
                  child: _testing
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Testa connessione'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(onPressed: _save, child: const Text('Salva')),
              ),
            ],
          ),
          if (_testResult != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_testOk ? Colors.green : Colors.red).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _testResult!,
                style: TextStyle(color: _testOk ? Colors.greenAccent : Colors.redAccent, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
