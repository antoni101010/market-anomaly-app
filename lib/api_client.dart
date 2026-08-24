import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const String _keyBaseUrl =
      'base_url';

  static const String _keyApiKey =
      'api_key';

  // Render gratuito può richiedere
  // circa 50 secondi per riattivare
  // un servizio che era fermo.
  static const Duration _requestTimeout =
      Duration(seconds: 75);

  static final ApiClient instance =
      ApiClient._();

  ApiClient._();

  String? _baseUrl;
  String? _apiKey;

  String? get baseUrl => _baseUrl;
  String? get apiKey => _apiKey;

  bool get isConfigured {
    return _baseUrl != null &&
        _baseUrl!.isNotEmpty &&
        _apiKey != null &&
        _apiKey!.isNotEmpty;
  }

  Future<void> load() async {
    final preferences =
        await SharedPreferences
            .getInstance();

    _baseUrl = preferences
        .getString(_keyBaseUrl)
        ?.trim();

    _apiKey = preferences
        .getString(_keyApiKey)
        ?.trim();
  }

  Future<void> save({
    required String baseUrl,
    required String apiKey,
  }) async {
    final preferences =
        await SharedPreferences
            .getInstance();

    final cleanedUrl =
        _cleanBaseUrl(baseUrl);

    final cleanedKey =
        apiKey.trim();

    await preferences.setString(
      _keyBaseUrl,
      cleanedUrl,
    );

    await preferences.setString(
      _keyApiKey,
      cleanedKey,
    );

    _baseUrl = cleanedUrl;
    _apiKey = cleanedKey;
  }

  String _cleanBaseUrl(
    String value,
  ) {
    var cleaned = value.trim();

    while (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(
        0,
        cleaned.length - 1,
      );
    }

    return cleaned;
  }

  Map<String, String> get _headers {
    return {
      'Accept': 'application/json',
      'Content-Type':
          'application/json',
      if (_apiKey != null &&
          _apiKey!.isNotEmpty)
        'X-API-Key': _apiKey!,
    };
  }

  Uri _uri(
    String path, [
    Map<String, dynamic>? query,
  ]) {
    final baseUrl = _baseUrl;

    if (baseUrl == null ||
        baseUrl.isEmpty) {
      throw ApiException(
        'Configura prima l’indirizzo '
        'del server nelle Impostazioni.',
      );
    }

    final queryParameters =
        query?.map(
      (key, value) => MapEntry(
        key,
        value.toString(),
      ),
    );

    return Uri.parse(
      '$baseUrl$path',
    ).replace(
      queryParameters:
          queryParameters,
    );
  }

  Future<dynamic> _get(
    String path, [
    Map<String, dynamic>? query,
  ]) async {
    try {
      final response = await http
          .get(
            _uri(path, query),
            headers: _headers,
          )
          .timeout(
            _requestTimeout,
          );

      return _handle(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'Il server sta impiegando troppo '
        'tempo a rispondere. Su Render '
        'gratuito può essere necessario '
        'attendere circa un minuto '
        'e riprovare.',
      );
    } catch (_) {
      throw ApiException(
        'Impossibile contattare il server. '
        'Controlla la connessione e '
        'l’indirizzo configurato.',
      );
    }
  }

  Future<dynamic> _post(
    String path, [
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  ]) async {
    try {
      final response = await http
          .post(
            _uri(path, query),
            headers: _headers,
            body: body == null
                ? null
                : jsonEncode(body),
          )
          .timeout(
            _requestTimeout,
          );

      return _handle(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'Il server sta impiegando troppo '
        'tempo a rispondere. '
        'Attendi circa un minuto '
        'e riprova.',
      );
    } catch (_) {
      throw ApiException(
        'Impossibile contattare il server. '
        'Controlla la connessione '
        'e riprova.',
      );
    }
  }

  Future<dynamic> _delete(
    String path,
  ) async {
    try {
      final response = await http
          .delete(
            _uri(path),
            headers: _headers,
          )
          .timeout(
            _requestTimeout,
          );

      return _handle(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'Il server sta impiegando troppo '
        'tempo a rispondere. '
        'Attendi e riprova.',
      );
    } catch (_) {
      throw ApiException(
        'Impossibile contattare '
        'il server.',
      );
    }
  }

  dynamic _handle(
    http.Response response,
  ) {
    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      throw ApiException(
        'Chiave API non valida. '
        'Controlla le Impostazioni.',
      );
    }

    if (response.statusCode >= 400) {
      var detail =
          'Richiesta non riuscita.';

      try {
        final decoded =
            jsonDecode(response.body);

        if (decoded
            is Map<String, dynamic>) {
          detail = decoded['detail']
                  ?.toString() ??
              decoded['message']
                  ?.toString() ??
              detail;
        }
      } catch (_) {
        if (response.body
                .trim()
                .isNotEmpty &&
            response.body.length <= 300) {
          detail =
              response.body.trim();
        }
      }

      throw ApiException(
        'Errore server '
        '(${response.statusCode}): '
        '$detail',
      );
    }

    if (response.body
        .trim()
        .isEmpty) {
      return null;
    }

    try {
      return jsonDecode(
        response.body,
      );
    } catch (_) {
      throw ApiException(
        'Il server ha restituito '
        'una risposta non valida.',
      );
    }
  }

  Future<Map<String, dynamic>>
      health() async {
    final response =
        await _get('/health');

    return response
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>>
      triggerScan({
    int limit = 100,
    int catalystTopN = 5,
  }) async {
    final response = await _post(
      '/api/scan',
      null,
      {
        'limit': limit,
        'catalyst_top_n':
            catalystTopN,
      },
    );

    return response
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>>
      getScanStatus() async {
    final response =
        await _get(
      '/api/scan/status',
    );

    return response
        as Map<String, dynamic>;
  }

  Future<DashboardData>
      getDashboard({
    double minOpportunity = 0,
    double maxValueTrap = 100,
    int topN = 20,
  }) async {
    final response = await _get(
      '/api/dashboard',
      {
        'min_opportunity':
            minOpportunity,
        'max_value_trap':
            maxValueTrap,
        'top_n': topN,
      },
    );

    return DashboardData.fromJson(
      response
          as Map<String, dynamic>,
    );
  }

  Future<TickerDetail>
      getTickerDetail(
    String ticker,
  ) async {
    final encodedTicker =
        Uri.encodeComponent(
      ticker
          .trim()
          .toUpperCase(),
    );

    final response =
        await _get(
      '/api/ticker/$encodedTicker',
    );

    return TickerDetail.fromJson(
      response
          as Map<String, dynamic>,
    );
  }

  Future<List<WatchlistItem>>
      getWatchlist() async {
    final response =
        await _get(
      '/api/watchlist',
    );

    return (response as List)
        .map(
          (item) =>
              WatchlistItem.fromJson(
            item
                as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> addToWatchlist(
    String ticker,
  ) async {
    final response = await _post(
      '/api/watchlist',
      {
        'ticker': ticker
            .trim()
            .toUpperCase(),
      },
    );

    final result = response
        as Map<String, dynamic>;

    if (result['ok'] != true) {
      throw ApiException(
        result['message']
                ?.toString() ??
            'Impossibile aggiungere '
                'il titolo alla watchlist.',
      );
    }
  }

  Future<void> removeFromWatchlist(
    String ticker,
  ) async {
    final encodedTicker =
        Uri.encodeComponent(
      ticker
          .trim()
          .toUpperCase(),
    );

    await _delete(
      '/api/watchlist/$encodedTicker',
    );
  }

  Future<List<HistoryEntry>>
      getHistory({
    int limit = 500,
  }) async {
    final response = await _get(
      '/api/history',
      {
        'limit': limit,
      },
    );

    return (response as List)
        .map(
          (item) =>
              HistoryEntry.fromJson(
            item
                as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
