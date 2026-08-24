import 'package:flutter/material.dart';

import 'api_client.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/watchlist_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient.instance.load();

  runApp(
    const MarketAnomalyApp(),
  );
}

class MarketAnomalyApp
    extends StatelessWidget {
  const MarketAnomalyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market Anomaly',
      debugShowCheckedModeBanner: false,
      theme: marketAnomalyTheme,
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({
    super.key,
  });

  @override
  State<RootScreen> createState() =>
      _RootScreenState();
}

class _RootScreenState
    extends State<RootScreen> {
  int _selectedIndex = 0;
  int _configurationVersion = 0;

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onSaved: () {
            if (!mounted) return;

            setState(() {
              _configurationVersion++;
            });
          },
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      _configurationVersion++;
    });
  }

  void _selectPage(int index) {
    if (index == _selectedIndex) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(
        key: ValueKey(
          'dashboard_$_configurationVersion',
        ),
        onOpenSettings: _openSettings,
      ),
      WatchlistScreen(
        key: ValueKey(
          'watchlist_$_configurationVersion',
        ),
      ),
      HistoryScreen(
        key: ValueKey(
          'history_$_configurationVersion',
        ),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.query_stats_outlined,
            ),
            selectedIcon: Icon(
              Icons.query_stats,
            ),
            label: 'Analisi',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.star_border,
            ),
            selectedIcon: Icon(
              Icons.star,
            ),
            label: 'Seguiti',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.history_outlined,
            ),
            selectedIcon: Icon(
              Icons.history,
            ),
            label: 'Storico',
          ),
        ],
      ),
    );
  }
}
