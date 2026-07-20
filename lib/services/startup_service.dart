import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/startup.dart';

class StartupService {
  final CollectionReference<Map<String, dynamic>> _startups =
      FirebaseFirestore.instance.collection('startups');

  Stream<Startup?> watchByOwner(String ownerUid) {
    return _startups
        .where('ownerUid', isEqualTo: ownerUid)
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : Startup.fromDoc(snap.docs.first));
  }

  Stream<List<Startup>> watchPending() {
    return _startups
        .where('verificationStatus',
            isEqualTo: VerificationStatus.pending.name)
        .snapshots()
        .map((snap) => snap.docs.map(Startup.fromDoc).toList());
  }

  Stream<List<Startup>> watchAll() {
    return _startups
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Startup.fromDoc).toList());
  }

  Stream<Startup?> watchById(String id) {
    return _startups
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? Startup.fromDoc(doc) : null);
  }

  Future<void> create(Startup startup) => _startups.add(startup.toMap());

  Future<void> updateProfile(String id,
      {required String name,
      required String sector,
      required String stage,
      required String description}) {
    return _startups.doc(id).update({
      'name': name,
      'sector': sector,
      'stage': stage,
      'description': description,
    });
  }

  Future<void> setVerification(String id, VerificationStatus status) =>
      _startups.doc(id).update({'verificationStatus': status.name});
}
