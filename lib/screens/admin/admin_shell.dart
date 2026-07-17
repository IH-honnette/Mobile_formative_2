import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/startup.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/startup_avatar.dart';
import '../../widgets/status_badge.dart';

/// Admin console: the verification queue plus an overview of every startup
/// on the platform. Admin accounts are created by promoting a user's role
/// to "admin" directly in the Firebase console — there is deliberately no
/// in-app path to becoming an admin.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pendingCount = context.watch<StartupProvider>().pending.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? 'Verification queue' : 'All startups'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _index == 0 ? const _PendingQueue() : const _AllStartups(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.coralSoft,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.pending_actions_rounded),
            ),
            label: 'Queue',
          ),
          const NavigationDestination(
              icon: Icon(Icons.storefront_outlined), label: 'Startups'),
        ],
      ),
    );
  }
}

class _PendingQueue extends StatelessWidget {
  const _PendingQueue();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StartupProvider>();
    final pending = provider.pending;

    if (pending.isEmpty) {
      return const EmptyState(
        icon: Icons.verified_rounded,
        title: 'Queue is clear',
        message:
            'New startups appear here the moment a founder submits a profile.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final startup = pending[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StartupAvatar(name: startup.name, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(startup.name,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          Text('${startup.sector} · ${startup.stage}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(startup.description,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            minimumSize: const Size.fromHeight(44)),
                        onPressed: () => provider.approve(startup.id),
                        icon: const Icon(Icons.verified_rounded, size: 18),
                        label: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.danger,
                            side: const BorderSide(color: AppTheme.danger),
                            minimumSize: const Size.fromHeight(44)),
                        onPressed: () => provider.reject(startup.id),
                        icon: const Icon(Icons.block_rounded, size: 18),
                        label: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AllStartups extends StatelessWidget {
  const _AllStartups();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Startup>>(
      stream: context.read<StartupProvider>().watchAll(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final startups = snapshot.data!;
        if (startups.isEmpty) {
          return const EmptyState(
            icon: Icons.storefront_outlined,
            title: 'No startups yet',
            message: 'Founder signups will show up here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: startups.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final startup = startups[i];
            return Card(
              child: ListTile(
                leading: StartupAvatar(name: startup.name, size: 40),
                title: Text(startup.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                subtitle: Text('${startup.sector} · ${startup.stage}'),
                trailing:
                    StatusBadge.verification(startup.verificationStatus),
              ),
            );
          },
        );
      },
    );
  }
}
