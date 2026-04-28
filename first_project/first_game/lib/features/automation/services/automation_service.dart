import '../models/automation_rule_model.dart';

class AutomationService {
  Future<List<AutomationRule>> fetchRules() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      AutomationRule(
        id: 'r1',
        name: 'Morning Routine',
        trigger: 'Time: 7:00 AM',
        condition: 'Weekday',
        action: 'Turn on all lights + Coffee maker',
        isEnabled: true,
      ),
      AutomationRule(
        id: 'r2',
        name: 'Leave Home',
        trigger: 'Location: Exit geofence',
        condition: 'Any time',
        action: 'Turn off all devices + Lock doors',
        isEnabled: true,
      ),
      AutomationRule(
        id: 'r3',
        name: 'Night Mode',
        trigger: 'Time: 11:00 PM',
        condition: 'Daily',
        action: 'Dim lights 20% + Set AC to 24°C',
        isEnabled: false,
      ),
      AutomationRule(
        id: 'r4',
        name: 'Motion Detected',
        trigger: 'Camera: Motion sensor',
        condition: 'After 10 PM',
        action: 'Turn on entrance light + Send alert',
        isEnabled: true,
      ),
    ];
  }

  Future<void> toggleRule(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
