import 'package:flutter/material.dart';

import 'analysis_preferences.dart';
import 'api_client.dart';
import 'legal_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/legal_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/watchlist_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.load();
  await LegalService.instance.load();
  final preferences = await AnalysisPreferences.load();

  runApp(
    MarketAnomalyApp(initialPreferences: preferences),
  );
}

class MarketAnomalyApp extends StatefulWidget {
  final AnalysisPreferences initialPreferences;

  const MarketAnomalyApp({
    super.key,
    required this.initialPreferences,
  });

  @override
  State<MarketAnomalyApp> createState() => _MarketAnomalyAppState();
}

class _MarketAnomalyAppState extends State<MarketAnomalyApp> {
  late bool _legalAccepted;

  @override
  void initState() {
    super.initState();
    _legalAccepted = LegalService.instance.hasAcceptedCurrent;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Anomaly',
      debugShowCheckedModeBanner: false,
      theme: marketAnomalyTheme,
      home: _legalAccepted
          ? RootScreen(
              initialPreferences: widget.initialPreferences,
              onLegalReset: () {
                if (!mounted) return;
                setState(() => _legalAccepted = false);
              },
            )
          : LegalAcceptanceScreen(
              onAccepted: () {
                if (!mounted) return;
                setState(() => _legalAccepted = true);
              },
            ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final AnalysisPreferences initialPreferences;
  final VoidCallback onLegalReset;

  const RootScreen({
    super.key,
    required this.initialPreferences,
    required this.onLegalReset,
  });

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  int _configurationVersion = 0;
  late AnalysisPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onLegalReset: widget.onLegalReset,
          onSaved: () {
            if (!mounted) return;
            setState(() => _configurationVersion++);
          },
        ),
      ),
    );

    if (mounted) setState(() => _configurationVersion++);
  }

  Future<void> _openPreferences() async {
    final result = await Navigator.of(context)
        .push<AnalysisPreferences>(
      MaterialPageRoute(
        builder: (_) => PreferencesScreen(initial: _preferences),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _preferences = result;
      _configurationVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(
        key: ValueKey('dashboard_$_configurationVersion'),
        onOpenSettings: _openSettings,
        onOpenPreferences: _openPreferences,
        preferences: _preferences,
      ),
      SearchScreen(
        key: ValueKey('search_$_configurationVersion'),
      ),
      WatchlistScreen(
        key: ValueKey('watchlist_$_configurationVersion'),
      ),
      HistoryScreen(
        key: ValueKey('history_$_configurationVersion'),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats),
            label: 'Analisi',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            selectedIcon: Icon(Icons.manage_search),
            label: 'Cerca',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Seguiti',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Storico',
          ),
        ],
      ),
    );
  }
}
