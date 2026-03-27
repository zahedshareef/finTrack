import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/data_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/debts/debts_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/more/more_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    DebtsScreen(),
    StatsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: AppTheme.surfaceVariant,
          indicatorColor: AppTheme.primary.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
            ),
            NavigationDestination(
              icon: Icon(Icons.handshake_outlined),
              selectedIcon: Icon(Icons.handshake),
              label: 'Debts',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined),
              selectedIcon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
