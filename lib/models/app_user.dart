import 'package:cloud_firestore/cloud_firestore.dart';

/// The three roles a signed-in person can have on Stint.
enum UserRole { student, founder, admin }

/// Profile document stored at `users/{uid}` in Firestore.
///
/// Kept separate from the FirebaseAuth account: Auth handles credentials,
/// this document holds everything the app needs to render a person.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final List<String> skills;
  final List<String> bookmarkedOpportunityIds;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.skills = const [],
    this.bookmarkedOpportunityIds = const [],
    required this.createdAt,
  });

  bool get isStudent => role == UserRole.student;
  bool get isFounder => role == UserRole.founder;
  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.student,
      ),
      skills: List<String>.from(data['skills'] as List? ?? []),
      bookmarkedOpportunityIds:
          List<String>.from(data['bookmarkedOpportunityIds'] as List? ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'skills': skills,
        'bookmarkedOpportunityIds': bookmarkedOpportunityIds,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
