import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  AuthStatus _status = AuthStatus.initializing;
  User? _firebaseUser;
  AppUser? _appUser;
  bool _busy = false;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  AuthProvider({AuthService? authService, UserService? userService})
      : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService() {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  AuthStatus get status => _status;
  AppUser? get user => _appUser;
  String get uid => _firebaseUser?.uid ?? '';
  bool get busy => _busy;

  void _onAuthChanged(User? firebaseUser) {
    _firebaseUser = firebaseUser;
    _profileSub?.cancel();

    if (firebaseUser == null) {
      _appUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _profileSub = _userService.watchUser(firebaseUser.uid).listen((profile) {
      _appUser = profile;
      _status = AuthStatus.authenticated;
      notifyListeners();
    });
  }

  static const String allowedDomain = 'alustudent.com';

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? validateEmailForRole(String email, UserRole role) {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) return 'Email is required.';
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    if (role == UserRole.student && !trimmed.endsWith('@$allowedDomain')) {
      return 'Use your ALU student email (@$allowedDomain).';
    }
    return null;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _setBusy(true);
    try {
      final credential = await _authService.signUp(
          email: email.trim(), password: password);
      await _userService.createUser(AppUser(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role,
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      throw AuthService.readableError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setBusy(true);
    try {
      await _authService.signIn(email: email.trim(), password: password);
    } catch (e) {
      throw AuthService.readableError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> updateSkills(List<String> skills) async {
    if (_appUser == null) return;
    await _userService.updateSkills(_appUser!.uid, skills);
  }

  bool isBookmarked(String opportunityId) =>
      _appUser?.bookmarkedOpportunityIds.contains(opportunityId) ?? false;

  Future<void> toggleBookmark(String opportunityId) async {
    if (_appUser == null) return;
    await _userService.toggleBookmark(
        _appUser!.uid, opportunityId, isBookmarked(opportunityId));
  }

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
