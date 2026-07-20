import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../models/startup.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/startup_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'post_opportunity_screen.dart';

class FounderDashboardScreen extends StatelessWidget {
  const FounderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final startup = context.watch<StartupProvider>().myStartup;
    if (startup == null) return const SizedBox.shrink();

    final opportunityProvider = context.read<OpportunityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My postings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
                child: StatusBadge.verification(startup.verificationStatus)),
          ),
        ],
      ),
      floatingActionButton: startup.isVerified
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.coral,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PostOpportunityScreen(startup: startup))),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Post opportunity'),
            )
          : null,
      body: Column(
        children: [
          if (!startup.isVerified) _verificationBanner(startup),
          Expanded(
            child: StreamBuilder<List<Opportunity>>(
              stream: opportunityProvider.watchByStartup(startup.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final postings = snapshot.data!;
                if (postings.isEmpty) {
                  return EmptyState(
                    icon: Icons.work_outline_rounded,
                    title: 'No postings yet',
                    message: startup.isVerified
                        ? 'Tap "Post opportunity" to recruit your first intern.'
                        : 'Once your startup is verified you can start posting opportunities.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: postings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _PostingTile(
                      opportunity: postings[i], startup: startup),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationBanner(Startup startup) {
    final rejected =
        startup.verificationStatus == VerificationStatus.rejected;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: rejected ? AppTheme.dangerSoft : AppTheme.warningSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(rejected ? Icons.block_rounded : Icons.hourglass_top_rounded,
              color: rejected ? AppTheme.danger : AppTheme.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rejected
                  ? 'Your startup was not approved. Update your profile in the Startup tab and contact the Stint team.'
                  : 'Your startup is awaiting verification. Posting unlocks as soon as an admin approves it — this screen updates automatically.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostingTile extends StatelessWidget {
  final Opportunity opportunity;
  final Startup startup;

  const _PostingTile({required this.opportunity, required this.startup});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OpportunityProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opportunity.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(
                    '${opportunity.category} · ${opportunity.paid ? 'Paid' : 'Unpaid'} · '
                    'closes ${DateFormat('MMM d').format(opportunity.deadline)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: opportunity.isOpen
                          ? AppTheme.successSoft
                          : const Color(0xFFEDEAE4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      opportunity.isOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: opportunity.isOpen
                            ? AppTheme.success
                            : AppTheme.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.inkMuted),
              onSelected: (action) async {
                switch (action) {
                  case 'edit':
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PostOpportunityScreen(
                            startup: startup, existing: opportunity)));
                  case 'toggle':
                    await provider.setOpen(
                        opportunity.id, !opportunity.isOpen);
                  case 'delete':
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete posting?'),
                        content: const Text(
                            'This permanently removes the opportunity. Applications already submitted stay visible in your Applicants tab.'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Delete',
                                  style:
                                      TextStyle(color: AppTheme.danger))),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await provider.delete(opportunity.id);
                    }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                    value: 'toggle',
                    child: Text(opportunity.isOpen
                        ? 'Close applications'
                        : 'Reopen applications')),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppTheme.danger))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
