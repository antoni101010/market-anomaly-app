import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Eccezione applicativa con messaggio già pronto per essere mostrato all'utente.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Client HTTP verso il backend Market Anomaly.
///
/// Base URL e chiave API sono configurabili dall'utente nella schermata
/// Impostazioni e salvati in locale sul dispositivo (SharedPreferences).
/// Nessuna chiave di dati finanziari (Twelve Data/Alpha Vantage) vive mai
/// nell'app: quelle restano solo lato server.
class ApiClient {
  static const _keyBaseUrl = 'base_url';
  static const _keyApiKey = 'api_key';

  String? _baseUrl;
  String? _apiKey;

  static final ApiClient instance = ApiClient._();
  ApiClient._();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_keyBaseUrl);
    _apiKey = prefs.getString(_keyApiKey);
  }

  bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;

  String? get baseUrl => _baseUrl;
  String? get apiKey => _apiKey;

  Future<void> save({required String baseUrl, required String apiKey}) async {
    final prefs = await SharedPreferences.getInstance();
    // Rimuove eventuale slash finale per costruire URL puliti.
    final cleaned = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    await prefs.setString(_keyBaseUrl, cleaned);
    await prefs.setString(_keyApiKey, apiKey);
    _baseUrl = cleaned;
    _apiKey = apiKey;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_apiKey != null && _apiKey!.isNotEmpty) 'X-API-Key': _apiKey!,
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    if (!isConfigured) {
      throw ApiException('Configura prima l\'indirizzo del server nelle Impostazioni.');
    }
    final qp = query?.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse('$_baseUrl$path').replace(queryParameters: qp);
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? query]) async {
    try {
      final r = await http
          .get(_uri(path, query), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handle(r);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Impossibile contattare il server: $e');
    }
  }

  Future<dynamic> _post(String path, [Map<String, dynamic>? body, Map<String, dynamic>? query]) async {
    try {
      final r = await http
          .post(_uri(path, query), headers: _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 60));
      return _handle(r);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Impossibile contattare il server: $e');
    }
  }

  Future<dynamic> _delete(String path) async {
    try {
      final r = await http.delete(_uri(path), headers: _headers).timeout(const Duration(seconds: 30));
      return _handle(r);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Impossibile contattare il server: $e');
    }
  }

  dynamic _handle(http.Response r) {
    if (r.statusCode == 401) {
      throw ApiException('Chiave API non valida. Controlla le Impostazioni.');
    }
    if (r.statusCode >= 400) {
      String detail = r.body;
      try {
        final j = jsonDecode(r.body);
        detail = j['detail']?.toString() ?? r.body;
      } catch (_) {}
      throw ApiException('Errore server (${r.statusCode}): $detail');
    }
    if (r.body.isEmpty) return null;
    return jsonDecode(r.body);
  }

  Future<Map<String, dynamic>> health() async {
    final r = await _get('/health');
    return r as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> triggerScan({int limit = 100}) async {
    final r = await _post('/api/scan', null, {'limit': limit});
    return r as Map<String, dynamic>;
  }

  Future<DashboardData> getDashboard({
    double minOpportunity = 55,
    double maxValueTrap = 65,
    int topN = 20,
  }) async {
    final r = await _get('/api/dashboard', {
      'min_opportunity': minOpportunity,
      'max_value_trap': maxValueTrap,
      'top_n': topN,
    });
    return DashboardData.fromJson(r as Map<String, dynamic>);
  }

  Future<TickerDetail> getTickerDetail(String ticker) async {
    final r = await _get('/api/ticker/$ticker');
    return TickerDetail.fromJson(r as Map<String, dynamic>);
  }

  Future<List<WatchlistItem>> getWatchlist() async {
    final r = await _get('/api/watchlist');
    return (r as List).map((e) => WatchlistItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addToWatchlist(String ticker) async {
    final r = await _post('/api/watchlist', {'ticker': ticker});
    final m = r as Map<String, dynamic>;
    if (m['ok'] != true) {
      throw ApiException(m['message'] ?? 'Impossibile aggiungere alla watchlist.');
    }
  }

  Future<void> removeFromWatchlist(String ticker) async {
    await _delete('/api/watchlist/$ticker');
  }

  Future<List<HistoryEntry>> getHistory({int limit = 500}) async {
    final r = await _get('/api/history', {'limit': limit});
    return (r as List).map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }
}
