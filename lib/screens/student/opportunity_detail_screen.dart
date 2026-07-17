import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/startup_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/startup_avatar.dart';

/// Full opportunity view with the startup's profile and the apply flow.
///
/// Watches the opportunity through OpportunityProvider (by id) rather than
/// taking a snapshot copy, so edits by the founder appear live even while a
/// student is reading the posting.
class OpportunityDetailScreen extends StatelessWidget {
  final String opportunityId;

  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final applications = context.watch<ApplicationProvider>();
    final opportunity =
        context.watch<OpportunityProvider>().byId(opportunityId);

    if (opportunity == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
            child: Text('This opportunity is no longer available.')),
      );
    }

    final skills = auth.user?.skills ?? const <String>[];
    final matches = opportunity.matchCount(skills);
    final alreadyApplied = applications.hasAppliedLocally(opportunity.id);
    final bookmarked = auth.isBookmarked(opportunity.id);
    final canApply = !alreadyApplied && !opportunity.deadlinePassed;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => auth.toggleBookmark(opportunity.id),
            icon: Icon(
              bookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: bookmarked ? AppTheme.coral : AppTheme.inkMuted,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Row(
            children: [
              StartupAvatar(name: opportunity.startupName, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunity.title,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 2),
                    Text(opportunity.startupName,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _fact(Icons.category_rounded, opportunity.category),
              _fact(Icons.payments_rounded,
                  opportunity.paid ? 'Paid' : 'Unpaid'),
              _fact(Icons.schedule_rounded, opportunity.commitment),
              _fact(
                  Icons.event_rounded,
                  opportunity.deadlinePassed
                      ? 'Deadline passed'
                      : 'Apply by ${DateFormat('MMM d, yyyy').format(opportunity.deadline)}'),
            ],
          ),
          if (matches > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.coralSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.task_alt_rounded,
                      color: AppTheme.coral, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You match $matches of ${opportunity.requiredSkills.length} required skills',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('About the role',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(opportunity.description,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          Text('Skills they need',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: opportunity.requiredSkills.map((skill) {
              final has =
                  skills.map((s) => s.toLowerCase()).contains(skill.toLowerCase());
              return Chip(
                label: Text(skill),
                avatar: has
                    ? const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppTheme.success)
                    : null,
                backgroundColor: has ? AppTheme.successSoft : Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _StartupCard(startupId: opportunity.startupId),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed:
                canApply ? () => _openApplySheet(context, opportunity) : null,
            child: Text(alreadyApplied
                ? 'Application submitted ✓'
                : opportunity.deadlinePassed
                    ? 'Deadline passed'
                    : 'Apply now'),
          ),
        ),
      ),
    );
  }

  Widget _fact(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.inkMuted),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _openApplySheet(BuildContext context, Opportunity opportunity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.sand,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ApplySheet(opportunity: opportunity),
    );
  }
}

/// Startup profile block shown under the posting — students should always
/// know who they're applying to, including verification status.
class _StartupCard extends StatelessWidget {
  final String startupId;

  const _StartupCard({required this.startupId});

  @override
  Widget build(BuildContext context) {
    final startupProvider = context.read<StartupProvider>();
    return StreamBuilder(
      stream: startupProvider.watchById(startupId),
      builder: (context, snapshot) {
        final startup = snapshot.data;
        if (startup == null) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('About ${startup.name}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 8),
                    if (startup.isVerified)
                      const Icon(Icons.verified_rounded,
                          size: 18, color: AppTheme.success),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${startup.sector} · ${startup.stage}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Text(startup.description,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ApplySheet extends StatefulWidget {
  final Opportunity opportunity;

  const _ApplySheet({required this.opportunity});

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _noteController.text.trim();
    if (note.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Tell the startup why you fit — at least 20 characters.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await context.read<ApplicationProvider>().apply(
            opportunity: widget.opportunity,
            student: context.read<AuthProvider>().user!,
            note: note,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Application sent! Track it in the Applications tab.')));
    } catch (message) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apply to ${widget.opportunity.title}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('at ${widget.opportunity.startupName}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText:
                  'Why are you a great fit? Mention relevant projects, courses or experience…',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Submit application'),
          ),
        ],
      ),
    );
  }
}
