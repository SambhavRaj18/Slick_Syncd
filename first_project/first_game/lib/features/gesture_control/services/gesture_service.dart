import '../models/gesture_model.dart';

class GestureService {
  final List<Map<String, dynamic>> _mappings = [
    {'type': GestureType.swipeUp,    'action': 'Brightness increased', 'device': 'Living Room Light'},
    {'type': GestureType.swipeDown,  'action': 'Brightness decreased', 'device': 'Living Room Light'},
    {'type': GestureType.swipeLeft,  'action': 'Previous track', 'device': 'Kitchen Speaker'},
    {'type': GestureType.swipeRight, 'action': 'Next track', 'device': 'Kitchen Speaker'},
    {'type': GestureType.hold,       'action': 'Toggle all lights', 'device': 'All Lights'},
    {'type': GestureType.pinch,      'action': 'Lower AC temperature', 'device': 'Air Conditioner'},
    {'type': GestureType.tap,        'action': 'Toggle device', 'device': 'Smart TV'},
    {'type': GestureType.rock,       'action': 'Toggle Rock Light', 'device': 'Rock Light'},
  ];

  Future<GestureModel> detectGesture() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = DateTime.now().millisecond % _mappings.length;
    final m = _mappings[idx];
    return GestureModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: m['type'] as GestureType,
      action: m['action'] as String,
      deviceTarget: m['device'] as String,
      detectedAt: DateTime.now(),
    );
  }

  List<Map<String, dynamic>> get allMappings => List.unmodifiable(_mappings);
}
