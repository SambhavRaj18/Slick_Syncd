import 'package:flutter/material.dart';
import 'models/gesture_model.dart';
import 'services/gesture_service.dart';

class GestureController extends ChangeNotifier {
  final GestureService _service = GestureService();

  bool _isDetecting = false;
  GestureModel? _lastGesture;
  final List<GestureModel> _history = [];
  String? _errorMessage;

  bool get isDetecting => _isDetecting;
  GestureModel? get lastGesture => _lastGesture;
  List<GestureModel> get history =>
      List.unmodifiable(_history.reversed.toList());
  String? get errorMessage => _errorMessage;

  Future<void> detectGesture() async {
    _isDetecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gesture = await _service.detectGesture();
      _lastGesture = gesture;
      _history.add(gesture);
    } catch (e) {
      _errorMessage = 'Gesture detection failed.';
    }

    _isDetecting = false;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _lastGesture = null;
    notifyListeners();
  }
}
