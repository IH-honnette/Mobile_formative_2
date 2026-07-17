import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

/// Reads and writes `users/{uid}` documents.
class UserService {
  final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Live stream of one user's profile. Emits null until the profile
  /// document has been created (i.e. mid-onboarding).
  Stream<AppUser?> watchUser(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);
  }

  Future<void> createUser(AppUser user) =>
      _users.doc(user.uid).set(user.toMap());

  Future<void> updateSkills(String uid, List<String> skills) =>
      _users.doc(uid).update({'skills': skills});

  Future<void> toggleBookmark(
      String uid, String opportunityId, bool bookmarked) {
    return _users.doc(uid).update({
      'bookmarkedOpportunityIds': bookmarked
          ? FieldValue.arrayRemove([opportunityId])
          : FieldValue.arrayUnion([opportunityId]),
    });
  }
}
