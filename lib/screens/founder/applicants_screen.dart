import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../providers/application_provider.dart';
import '../../providers/startup_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final startup = context.watch<StartupProvider>().myStartup;
    if (startup == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: StreamBuilder<List<Application>>(
        stream:
            context.read<ApplicationProvider>().watchByStartup(startup.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final applications = snapshot.data!;
          if (applications.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No applicants yet',
              message:
                  'When students apply to your postings, their applications appear here for review.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _ApplicantTile(application: applications[i]),
          );
        },
      ),
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  final Application application;

  const _ApplicantTile({required this.application});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ApplicationProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.navy,
                  child: Text(
                    application.studentName.isNotEmpty
                        ? application.studentName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.studentName,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        'For: ${application.opportunityTitle} · ${DateFormat('MMM d').format(application.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusBadge.application(application.status),
              ],
            ),
            if (application.studentSkills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: application.studentSkills
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.navy)),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.sand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('“${application.note}”',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            if (!application.isDecided) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (application.status == ApplicationStatus.submitted)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(42)),
                        onPressed: () => provider.updateStatus(
                            application.id, ApplicationStatus.reviewed),
                        child: const Text('Mark reviewed'),
                      ),
                    ),
                  if (application.status == ApplicationStatus.submitted)
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          minimumSize: const Size.fromHeight(42)),
                      onPressed: () => provider.updateStatus(
                          application.id, ApplicationStatus.accepted),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.danger,
                          minimumSize: const Size.fromHeight(42)),
                      onPressed: () => provider.updateStatus(
                          application.id, ApplicationStatus.rejected),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
