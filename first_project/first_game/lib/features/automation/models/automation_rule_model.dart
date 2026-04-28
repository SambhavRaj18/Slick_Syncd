
class AutomationRule {
  final String id;
  String name;
  String trigger;
  String condition;
  String action;
  bool isEnabled;

  AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    required this.condition,
    required this.action,
    this.isEnabled = true,
  });
}
