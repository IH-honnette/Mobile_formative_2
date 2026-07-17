import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/startup.dart';
import '../services/startup_service.dart';

/// Startup state for the signed-in person.
///
/// Founder: follows their own startup document (or null before creation).
/// Admin: follows the pending-verification queue.
/// [bindSession] is called by ChangeNotifierProxyProvider whenever the
/// session changes, so subscriptions always track the current user.
class StartupProvider extends ChangeNotifier {
  final StartupService _service;

  Startup? _myStartup;
  bool _loadingMine = false;
  List<Startup> _pending = [];
  String? _boundUid;

  StreamSubscription<Startup?>? _mineSub;
  StreamSubscription<List<Startup>>? _pendingSub;

  StartupProvider({StartupService? service})
      : _service = service ?? StartupService();

  /// Re-points the live subscriptions at the current session. No-op when
  /// nothing changed, so rebuilds never duplicate listeners. The key includes
  /// the role flags because the profile document (which carries the role)
  /// arrives a moment after FirebaseAuth reports the uid.
  void bindSession({
    required String uid,
    required bool isFounder,
    required bool isAdmin,
  }) {
    final key = '$uid:$isFounder:$isAdmin';
    if (key == _boundUid) return;
    _boundUid = key;
    _mineSub?.cancel();
    _pendingSub?.cancel();
    _myStartup = null;
    _pending = [];

    if (uid.isEmpty) {
      _loadingMine = false;
      return;
    }

    if (isFounder) {
      _loadingMine = true;
      _mineSub = _service.watchByOwner(uid).listen((startup) {
        _myStartup = startup;
        _loadingMine = false;
        notifyListeners();
      });
    }

    if (isAdmin) {
      _pendingSub = _service.watchPending().listen((startups) {
        _pending = startups;
        notifyListeners();
      });
    }
  }

  Startup? get myStartup => _myStartup;
  bool get loadingMine => _loadingMine;
  List<Startup> get pending => List.unmodifiable(_pending);

  Stream<List<Startup>> watchAll() => _service.watchAll();
  Stream<Startup?> watchById(String id) => _service.watchById(id);

  Future<void> createStartup({
    required String ownerUid,
    required String name,
    required String sector,
    required String stage,
    required String description,
  }) {
    return _service.create(Startup(
      id: '',
      ownerUid: ownerUid,
      name: name.trim(),
      sector: sector,
      stage: stage,
      description: description.trim(),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> updateProfile({
    required String id,
    required String name,
    required String sector,
    required String stage,
    required String description,
  }) {
    return _service.updateProfile(id,
        name: name.trim(),
        sector: sector,
        stage: stage,
        description: description.trim());
  }

  Future<void> approve(String id) =>
      _service.setVerification(id, VerificationStatus.verified);

  Future<void> reject(String id) =>
      _service.setVerification(id, VerificationStatus.rejected);

  @override
  void dispose() {
    _mineSub?.cancel();
    _pendingSub?.cancel();
    super.dispose();
  }
}
