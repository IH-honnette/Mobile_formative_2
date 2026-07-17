import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../providers/application_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/startup_avatar.dart';
import '../../widgets/status_badge.dart';

/// Application tracking — the feature that turns "apply and pray" into a
/// transparent pipeline. Status changes made by founders appear here in
/// real time through the Firestore stream.
class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My applications')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.mine.isEmpty
              ? const EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No applications yet',
                  message:
                      'When you apply to an opportunity it shows up here, with live status updates from the startup.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.mine.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _ApplicationTile(application: provider.mine[i]),
                ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final Application application;

  const _ApplicationTile({required this.application});

  static const _steps = [
    ApplicationStatus.submitted,
    ApplicationStatus.reviewed,
    ApplicationStatus.accepted,
  ];

  @override
  Widget build(BuildContext context) {
    final rejected = application.status == ApplicationStatus.rejected;
    final currentStep = rejected
        ? 1
        : _steps.indexOf(application.status).clamp(0, _steps.length - 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StartupAvatar(name: application.startupName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(application.opportunityTitle,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(application.startupName,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusBadge.application(application.status),
              ],
            ),
            const SizedBox(height: 14),
            // Mini pipeline: submitted → reviewed → accepted (or rejected).
            Row(
              children: List.generate(_steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final reached = (i - 1) ~/ 2 < currentStep;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: reached
                            ? (rejected ? AppTheme.danger : AppTheme.success)
                            : AppTheme.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }
                final step = i ~/ 2;
                final reached = step <= currentStep;
                final isEnd = step == _steps.length - 1;
                final color = rejected
                    ? (step <= 1 ? AppTheme.danger : AppTheme.line)
                    : reached
                        ? AppTheme.success
                        : AppTheme.line;
                return Icon(
                  rejected && isEnd
                      ? Icons.cancel_rounded
                      : reached
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                  size: 18,
                  color: color,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Applied ${DateFormat('MMM d, yyyy').format(application.createdAt)}'
              '${application.isDecided ? ' · Decided ${DateFormat('MMM d').format(application.updatedAt)}' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
