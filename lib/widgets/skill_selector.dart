import 'package:flutter/material.dart';

import '../models/opportunity.dart';
import '../theme/app_theme.dart';

/// Chip-based skill picker reused in three places: student onboarding,
/// profile editing and opportunity posting. Selecting from a shared
/// vocabulary is what makes skill matching work.
class SkillSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const SkillSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kSkillSuggestions.map((skill) {
        final isSelected = selected.contains(skill);
        return FilterChip(
          label: Text(skill),
          selected: isSelected,
          onSelected: (_) {
            final next = List<String>.from(selected);
            isSelected ? next.remove(skill) : next.add(skill);
            onChanged(next);
          },
          selectedColor: AppTheme.navy,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.ink,
          ),
        );
      }).toList(),
    );
  }
}
