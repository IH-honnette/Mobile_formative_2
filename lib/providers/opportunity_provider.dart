import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/opportunity.dart';
import '../services/opportunity_service.dart';

/// Owns the discovery feed: one live subscription to all open opportunities
/// plus the student's search/filter/sort state. Screens read [visible] and
/// never touch Firestore directly.
class OpportunityProvider extends ChangeNotifier {
  final OpportunityService _service;

  List<Opportunity> _all = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _categoryFilter;
  bool _sortByMatch = false;

  StreamSubscription<List<Opportunity>>? _sub;

  OpportunityProvider({OpportunityService? service})
      : _service = service ?? OpportunityService() {
    _sub = _service.watchOpen().listen((opportunities) {
      _all = opportunities;
      _loading = false;
      notifyListeners();
    }, onError: (_) {
      _loading = false;
      notifyListeners();
    });
  }

  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  bool get sortByMatch => _sortByMatch;
  List<Opportunity> get all => List.unmodifiable(_all);

  /// The feed after search, category filter and optional match-sorting.
  /// [studentSkills] comes from AuthProvider at the call site.
  List<Opportunity> visible(List<String> studentSkills) {
    final query = _searchQuery.trim().toLowerCase();
    var list = _all.where((o) {
      final matchesQuery = query.isEmpty ||
          o.title.toLowerCase().contains(query) ||
          o.startupName.toLowerCase().contains(query) ||
          o.requiredSkills.any((s) => s.toLowerCase().contains(query));
      final matchesCategory =
          _categoryFilter == null || o.category == _categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    if (_sortByMatch) {
      list.sort((a, b) =>
          b.matchCount(studentSkills).compareTo(a.matchCount(studentSkills)));
    }
    return list;
  }

  Opportunity? byId(String id) {
    for (final o in _all) {
      if (o.id == id) return o;
    }
    return null;
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void toggleSortByMatch() {
    _sortByMatch = !_sortByMatch;
    notifyListeners();
  }

  // --- Founder actions (writes flow back into _all via the stream) ---

  Stream<List<Opportunity>> watchByStartup(String startupId) =>
      _service.watchByStartup(startupId);

  Future<void> create(Opportunity opportunity) => _service.create(opportunity);

  Future<void> update(String id, Map<String, dynamic> fields) =>
      _service.update(id, fields);

  Future<void> setOpen(String id, bool isOpen) => _service.setOpen(id, isOpen);

  Future<void> delete(String id) => _service.delete(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
