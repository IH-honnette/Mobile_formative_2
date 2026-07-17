import 'package:cloud_firestore/cloud_firestore.dart';

/// Verification lifecycle of a startup profile.
///
/// Startups begin as [pending]; an admin moves them to [verified] or
/// [rejected]. Only verified startups may post opportunities — this is the
/// trust layer that keeps ghost startups off the platform.
enum VerificationStatus { pending, verified, rejected }

/// Document stored at `startups/{id}` in Firestore.
class Startup {
  final String id;
  final String ownerUid;
  final String name;
  final String sector;
  final String stage;
  final String description;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;

  const Startup({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.sector,
    required this.stage,
    required this.description,
    this.verificationStatus = VerificationStatus.pending,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Two-letter monogram used for the avatar (e.g. "Kigali Grocers" → "KG").
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  factory Startup.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Startup(
      id: doc.id,
      ownerUid: data['ownerUid'] as String? ?? '',
      name: data['name'] as String? ?? '',
      sector: data['sector'] as String? ?? '',
      stage: data['stage'] as String? ?? '',
      description: data['description'] as String? ?? '',
      verificationStatus: VerificationStatus.values.firstWhere(
        (s) => s.name == data['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerUid': ownerUid,
        'name': name,
        'sector': sector,
        'stage': stage,
        'description': description,
        'verificationStatus': verificationStatus.name,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
