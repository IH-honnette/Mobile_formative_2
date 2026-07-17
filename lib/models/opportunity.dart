import 'package:cloud_firestore/cloud_firestore.dart';

/// Role categories a startup can recruit for. Kept as a fixed list so
/// filtering stays predictable and the UI can render category chips.
const List<String> kOpportunityCategories = [
  'Software Development',
  'Design',
  'Marketing',
  'Operations',
  'Research',
  'Business Analysis',
  'Content Creation',
  'Community Management',
];

/// Skills students can tag themselves with and startups can require.
/// A shared vocabulary keeps skill matching meaningful — free-text skills
/// would rarely intersect.
const List<String> kSkillSuggestions = [
  'Flutter',
  'Mobile Development',
  'Web Development',
  'UI/UX Design',
  'Graphic Design',
  'Digital Marketing',
  'Social Media',
  'Content Writing',
  'Video Editing',
  'Data Analysis',
  'Research',
  'Business Analysis',
  'Finance',
  'Operations',
  'Sales',
  'Community Management',
  'Photography',
  'Public Speaking',
];

/// Document stored at `opportunities/{id}` in Firestore.
///
/// `startupName` is denormalized from the startup document so opportunity
/// cards render without an extra read per card — a deliberate Firestore
/// trade-off (reads are the dominant cost at scale).
class Opportunity {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category;
  final List<String> requiredSkills;
  final bool paid;
  final String commitment;
  final DateTime deadline;
  final bool isOpen;
  final DateTime createdAt;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    this.requiredSkills = const [],
    this.paid = false,
    required this.commitment,
    required this.deadline,
    this.isOpen = true,
    required this.createdAt,
  });

  bool get deadlinePassed => DateTime.now().isAfter(deadline);

  /// How many of the student's skills appear in [requiredSkills].
  /// Powers the "Matches N of your skills" badge and match-based sorting.
  int matchCount(List<String> studentSkills) {
    final wanted = requiredSkills.map((s) => s.toLowerCase()).toSet();
    return studentSkills.where((s) => wanted.contains(s.toLowerCase())).length;
  }

  factory Opportunity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      requiredSkills: List<String>.from(data['requiredSkills'] as List? ?? []),
      paid: data['paid'] as bool? ?? false,
      commitment: data['commitment'] as String? ?? '',
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOpen: data['isOpen'] as bool? ?? true,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'startupId': startupId,
        'startupName': startupName,
        'title': title,
        'description': description,
        'category': category,
        'requiredSkills': requiredSkills,
        'paid': paid,
        'commitment': commitment,
        'deadline': Timestamp.fromDate(deadline),
        'isOpen': isOpen,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
