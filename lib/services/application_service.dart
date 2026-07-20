import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application.dart';

class ApplicationService {
  final CollectionReference<Map<String, dynamic>> _applications =
      FirebaseFirestore.instance.collection('applications');

  Stream<List<Application>> watchByStudent(String studentUid) {
    return _applications
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(Application.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Application>> watchByStartup(String startupId) {
    return _applications
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(Application.fromDoc).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<bool> hasApplied(String studentUid, String opportunityId) async {
    final snap = await _applications
        .where('studentUid', isEqualTo: studentUid)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submit(Application application) =>
      _applications.add(application.toMap());

  Future<void> updateStatus(String id, ApplicationStatus status) {
    return _applications.doc(id).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }
}
