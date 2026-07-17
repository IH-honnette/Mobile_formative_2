import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/opportunity.dart';

/// Reads and writes `opportunities/{id}` documents.
class OpportunityService {
  final CollectionReference<Map<String, dynamic>> _opportunities =
      FirebaseFirestore.instance.collection('opportunities');

  /// Every open opportunity, newest first — the student discovery feed.
  /// Search and category filtering happen client-side in the provider,
  /// which is fine at campus scale and avoids composite-index sprawl.
  Stream<List<Opportunity>> watchOpen() {
    return _opportunities
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(Opportunity.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// All postings by one startup — the founder's dashboard list.
  Stream<List<Opportunity>> watchByStartup(String startupId) {
    return _opportunities
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(Opportunity.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> create(Opportunity opportunity) =>
      _opportunities.add(opportunity.toMap());

  Future<void> update(String id, Map<String, dynamic> fields) =>
      _opportunities.doc(id).update(fields);

  Future<void> setOpen(String id, bool isOpen) =>
      _opportunities.doc(id).update({'isOpen': isOpen});

  Future<void> delete(String id) => _opportunities.doc(id).delete();
}
