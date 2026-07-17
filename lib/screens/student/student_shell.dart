import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'bookmarks_screen.dart';
import 'discover_screen.dart';
import 'my_applications_screen.dart';
import 'student_profile_screen.dart';

/// Bottom-navigation shell for the student experience.
/// IndexedStack keeps each tab's scroll position and state alive.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _screens = [
    DiscoverScreen(),
    BookmarksScreen(),
    MyApplicationsScreen(),
    StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.coralSoft,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.coral),
              label: 'Discover'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.coral),
              label: 'Saved'),
          NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon:
                  Icon(Icons.assignment_rounded, color: AppTheme.coral),
              label: 'Applications'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.coral),
              label: 'Profile'),
        ],
      ),
    );
  }
}
