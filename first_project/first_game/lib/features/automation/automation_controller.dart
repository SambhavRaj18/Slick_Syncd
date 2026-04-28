import 'package:flutter/material.dart';
import 'models/automation_rule_model.dart';
import 'services/automation_service.dart';

class AutomationController extends ChangeNotifier {
  final AutomationService _service = AutomationService();

  List<AutomationRule> _rules = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AutomationRule> get rules => List.unmodifiable(_rules);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get activeRulesCount => _rules.where((r) => r.isEnabled).length;

  AutomationController() {
    _loadRules();
  }

  Future<void> _loadRules() async {
    _isLoading = true;
    notifyListeners();
    try {
      _rules = await _service.fetchRules();
    } catch (_) {
      _errorMessage = 'Could not load automation rules.';
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleRule(String id) {
    final idx = _rules.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _rules[idx].isEnabled = !_rules[idx].isEnabled;
      notifyListeners();
    }
  }

  void addRule(AutomationRule rule) {
    _rules.add(rule);
    notifyListeners();
  }

  void removeRule(String id) {
    _rules.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
