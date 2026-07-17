import 'package:cloud_firestore/cloud_firestore.dart';

/// Pipeline an application moves through. Founders drive the transitions;
/// students watch them happen in real time on the tracking screen.
enum ApplicationStatus { submitted, reviewed, accepted, rejected }

/// Document stored at `applications/{id}` in Firestore.
///
/// Opportunity title, startup name and student name are denormalized so both
/// the student's tracking list and the founder's applicant list render from a
/// single query with no joins.
class Application {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentUid;
  final String studentName;
  final List<String> studentSkills;
  final String note;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentUid,
    required this.studentName,
    this.studentSkills = const [],
    required this.note,
    this.status = ApplicationStatus.submitted,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDecided =>
      status == ApplicationStatus.accepted ||
      status == ApplicationStatus.rejected;

  factory Application.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Application(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentUid: data['studentUid'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      studentSkills: List<String>.from(data['studentSkills'] as List? ?? []),
      note: data['note'] as String? ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApplicationStatus.submitted,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'opportunityId': opportunityId,
        'opportunityTitle': opportunityTitle,
        'startupId': startupId,
        'startupName': startupName,
        'studentUid': studentUid,
        'studentName': studentName,
        'studentSkills': studentSkills,
        'note': note,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
