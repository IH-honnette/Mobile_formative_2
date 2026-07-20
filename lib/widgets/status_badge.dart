import 'package:flutter/material.dart';

import '../models/application.dart';
import '../models/startup.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const StatusBadge._(this.label, this.color, this.background);

  factory StatusBadge.application(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return const StatusBadge._(
            'Submitted', AppTheme.navy, Color(0xFFE8EDF6));
      case ApplicationStatus.reviewed:
        return const StatusBadge._(
            'Reviewed', AppTheme.warning, AppTheme.warningSoft);
      case ApplicationStatus.accepted:
        return const StatusBadge._(
            'Accepted', AppTheme.success, AppTheme.successSoft);
      case ApplicationStatus.rejected:
        return const StatusBadge._(
            'Rejected', AppTheme.danger, AppTheme.dangerSoft);
    }
  }

  factory StatusBadge.verification(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return const StatusBadge._(
            'Pending review', AppTheme.warning, AppTheme.warningSoft);
      case VerificationStatus.verified:
        return const StatusBadge._(
            'Verified', AppTheme.success, AppTheme.successSoft);
      case VerificationStatus.rejected:
        return const StatusBadge._(
            'Rejected', AppTheme.danger, AppTheme.dangerSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
