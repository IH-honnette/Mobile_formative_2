import 'package:cloud_firestore/cloud_firestore.dart';

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
