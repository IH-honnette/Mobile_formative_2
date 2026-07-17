import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../admin/admin_shell.dart';
import '../auth/login_screen.dart';
import '../founder/founder_shell.dart';
import '../student/student_shell.dart';

/// Single routing decision for the whole app: watches AuthProvider and
/// swaps the visible tree between login, loading and the three role shells.
/// Because this is driven by provider state, login/logout transitions happen
/// automatically with no manual navigation calls.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initializing:
        return const _Splash();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        final user = auth.user;
        // Signed in but the profile document hasn't arrived yet.
        if (user == null) return const _Splash();
        switch (user.role) {
          case UserRole.student:
            return const StudentShell();
          case UserRole.founder:
            return const FounderShell();
          case UserRole.admin:
            return const AdminShell();
        }
    }
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.coral,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.rocket_launch_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Stint',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                  color: Colors.white54, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
