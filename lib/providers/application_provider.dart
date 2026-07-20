import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/application.dart';
import '../models/app_user.dart';
import '../models/opportunity.dart';
import '../services/application_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationService _service;

  List<Application> _mine = [];
  bool _loading = false;
  String? _boundUid;

  StreamSubscription<List<Application>>? _mineSub;

  ApplicationProvider({ApplicationService? service})
      : _service = service ?? ApplicationService();

  void bindStudent(String uid) {
    if (uid == _boundUid) return;
    _boundUid = uid;
    _mineSub?.cancel();
    _mine = [];

    if (uid.isEmpty) {
      _loading = false;
      return;
    }
    _loading = true;
    _mineSub = _service.watchByStudent(uid).listen((applications) {
      _mine = applications;
      _loading = false;
      notifyListeners();
    });
  }

  List<Application> get mine => List.unmodifiable(_mine);
  bool get loading => _loading;

  bool hasAppliedLocally(String opportunityId) =>
      _mine.any((a) => a.opportunityId == opportunityId);

  Future<void> apply({
    required Opportunity opportunity,
    required AppUser student,
    required String note,
  }) async {
    final already =
        await _service.hasApplied(student.uid, opportunity.id);
    if (already) {
      throw 'You have already applied to this opportunity.';
    }
    final now = DateTime.now();
    await _service.submit(Application(
      id: '',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      studentUid: student.uid,
      studentName: student.name,
      studentSkills: student.skills,
      note: note.trim(),
      createdAt: now,
      updatedAt: now,
    ));
  }

  Stream<List<Application>> watchByStartup(String startupId) =>
      _service.watchByStartup(startupId);

  Future<void> updateStatus(String applicationId, ApplicationStatus status) =>
      _service.updateStatus(applicationId, status);

  @override
  void dispose() {
    _mineSub?.cancel();
    super.dispose();
  }
}
