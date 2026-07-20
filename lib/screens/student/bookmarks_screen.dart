import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<OpportunityProvider>();
    final skills = auth.user?.skills ?? const <String>[];
    final bookmarkedIds = auth.user?.bookmarkedOpportunityIds ?? const [];
    final saved = provider.all
        .where((o) => bookmarkedIds.contains(o.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved opportunities')),
      body: saved.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'Nothing saved yet',
              message:
                  'Tap the bookmark icon on any opportunity to keep it here for later.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final opportunity = saved[i];
                return OpportunityCard(
                  opportunity: opportunity,
                  studentSkills: skills,
                  bookmarked: true,
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
    );
  }
}
