import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/startup_provider.dart';
import '../../theme/app_theme.dart';
import 'applicants_screen.dart';
import 'create_startup_screen.dart';
import 'founder_dashboard_screen.dart';
import 'startup_profile_screen.dart';

class FounderShell extends StatefulWidget {
  const FounderShell({super.key});

  @override
  State<FounderShell> createState() => _FounderShellState();
}

class _FounderShellState extends State<FounderShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final startupProvider = context.watch<StartupProvider>();

    if (startupProvider.loadingMine) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (startupProvider.myStartup == null) {
      return const CreateStartupScreen();
    }

    final screens = const [
      FounderDashboardScreen(),
      ApplicantsScreen(),
      StartupProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.coralSoft,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.work_outline_rounded),
              selectedIcon: Icon(Icons.work_rounded, color: AppTheme.coral),
              label: 'Postings'),
          NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded, color: AppTheme.coral),
              label: 'Applicants'),
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon:
                  Icon(Icons.storefront_rounded, color: AppTheme.coral),
              label: 'Startup'),
        ],
      ),
    );
  }
}
