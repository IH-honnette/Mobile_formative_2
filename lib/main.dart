import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'providers/application_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/opportunity_provider.dart';
import 'providers/startup_provider.dart';
import 'screens/shared/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StintApp());
}

/// Provider wiring for the whole app.
///
/// AuthProvider is the root of the graph; the session-scoped providers
/// (startups, applications) are re-bound through ChangeNotifierProxyProvider
/// whenever the signed-in user changes, so no screen ever holds state that
/// belongs to a previous session.
class StintApp extends StatelessWidget {
  const StintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OpportunityProvider()),
        ChangeNotifierProxyProvider<AuthProvider, StartupProvider>(
          create: (_) => StartupProvider(),
          update: (_, auth, startupProvider) => startupProvider!
            ..bindSession(
              uid: auth.uid,
              isFounder: auth.user?.role == UserRole.founder,
              isAdmin: auth.user?.role == UserRole.admin,
            ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ApplicationProvider>(
          create: (_) => ApplicationProvider(),
          update: (_, auth, applicationProvider) => applicationProvider!
            ..bindStudent(auth.user?.isStudent == true ? auth.uid : ''),
        ),
      ],
      child: MaterialApp(
        title: 'Stint',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}
