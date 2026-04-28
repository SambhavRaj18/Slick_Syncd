enum GestureType { swipeUp, swipeDown, swipeLeft, swipeRight, tap, hold, pinch, rock }

class GestureModel {
  final String id;
  final GestureType type;
  final String action;
  final String deviceTarget;
  final DateTime detectedAt;

  const GestureModel({
    required this.id,
    required this.type,
    required this.action,
    required this.deviceTarget,
    required this.detectedAt,
  });

  String get typeLabel {
    switch (type) {
      case GestureType.swipeUp:    return '👆 Swipe Up';
      case GestureType.swipeDown:  return '👇 Swipe Down';
      case GestureType.swipeLeft:  return '👈 Swipe Left';
      case GestureType.swipeRight: return '👉 Swipe Right';
      case GestureType.tap:        return '👆 Tap';
      case GestureType.hold:       return '✋ Hold';
      case GestureType.pinch:      return '🤏 Pinch';
      case GestureType.rock:       return '🤘 Rock On';
    }
  }
}
