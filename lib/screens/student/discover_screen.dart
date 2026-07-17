import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';
import 'student_profile_screen.dart';

/// The heart of the student experience: live feed of open opportunities
/// with search, category filters and skill-match sorting. Everything here
/// re-renders automatically when Firestore pushes a change.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<OpportunityProvider>();
    final skills = auth.user?.skills ?? const <String>[];
    final opportunities = provider.visible(skills);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${auth.user?.name.split(' ').first ?? 'there'}'),
        actions: [
          IconButton(
            tooltip: provider.sortByMatch
                ? 'Sorted by skill match'
                : 'Sort by skill match',
            onPressed: provider.toggleSortByMatch,
            icon: Icon(
              Icons.swap_vert_rounded,
              color:
                  provider.sortByMatch ? AppTheme.coral : AppTheme.inkMuted,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search roles, startups or skills…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _categoryChip(context, provider, null, 'All'),
                for (final category in kOpportunityCategories)
                  _categoryChip(context, provider, category, category),
              ],
            ),
          ),
          if (skills.isEmpty) _skillsPrompt(context),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : opportunities.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No opportunities found',
                        message:
                            'Try a different search or filter — new roles are posted by ALU startups all the time.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: opportunities.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final opportunity = opportunities[i];
                          return OpportunityCard(
                            opportunity: opportunity,
                            studentSkills: skills,
                            bookmarked: auth.isBookmarked(opportunity.id),
                            onBookmarkToggle: () =>
                                auth.toggleBookmark(opportunity.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OpportunityDetailScreen(
                                    opportunityId: opportunity.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(BuildContext context, OpportunityProvider provider,
      String? value, String label) {
    final selected = provider.categoryFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => provider.setCategoryFilter(value),
        selectedColor: AppTheme.navy,
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppTheme.ink,
        ),
      ),
    );
  }

  Widget _skillsPrompt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: AppTheme.coralSoft,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StudentProfileScreen(standalone: true))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.edit_note_rounded,
                    color: AppTheme.coral, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Add your skills to unlock personalized matching',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ink.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppTheme.coral),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
