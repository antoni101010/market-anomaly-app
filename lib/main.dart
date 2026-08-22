import 'package:flutter/material.dart';
import 'api_client.dart';
import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.load();
  runApp(const MarketAnomalyApp());
}

class MarketAnomalyApp extends StatelessWidget {
  const MarketAnomalyApp({super.key});

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
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => SettingsScreen(onSaved: () => setState(() {}))))
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onOpenSettings: _openSettings),
      const WatchlistScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: 'Watchlist'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'Storico'),
        ],
      ),
    );
  }
}
