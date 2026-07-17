import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/opportunity.dart';
import '../theme/app_theme.dart';
import 'startup_avatar.dart';

/// Card used in the discovery feed and bookmarks list.
///
/// Shows the skill-match badge when the student has matching skills — the
/// signal that makes browsing feel personal instead of generic.
class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final List<String> studentSkills;
  final bool bookmarked;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkToggle;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.studentSkills = const [],
    this.bookmarked = false,
    required this.onTap,
    this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final matches = opportunity.matchCount(studentSkills);
    final deadlineLabel =
        DateFormat('MMM d').format(opportunity.deadline);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StartupAvatar(name: opportunity.startupName, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opportunity.title,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(opportunity.startupName,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (onBookmarkToggle != null)
                    IconButton(
                      onPressed: onBookmarkToggle,
                      icon: Icon(
                        bookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: bookmarked ? AppTheme.coral : AppTheme.inkMuted,
                      ),
                      tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _pill(opportunity.category, const Color(0xFFE8EDF6),
                      AppTheme.navy),
                  _pill(
                      opportunity.paid ? 'Paid' : 'Unpaid',
                      opportunity.paid
                          ? AppTheme.successSoft
                          : const Color(0xFFEDEAE4),
                      opportunity.paid ? AppTheme.success : AppTheme.inkMuted),
                  _pill(opportunity.commitment, const Color(0xFFEDEAE4),
                      AppTheme.inkMuted),
                  if (matches > 0)
                    _pill('Matches $matches of your skills',
                        AppTheme.coralSoft, AppTheme.coral),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 15, color: AppTheme.inkMuted),
                  const SizedBox(width: 5),
                  Text(
                    opportunity.deadlinePassed
                        ? 'Deadline passed'
                        : 'Apply by $deadlineLabel',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: opportunity.deadlinePassed
                          ? AppTheme.danger
                          : AppTheme.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
