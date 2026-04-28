import 'package:flutter/material.dart';
import 'models/device_model.dart';
import 'repositories/device_repository.dart';

class DeviceController extends ChangeNotifier {
  final IDeviceRepository _deviceRepository;

  DeviceController(this._deviceRepository) {
    fetchDevices();
  }

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<Device> get devices => List.unmodifiable(_devices);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get onlineCount => _devices.where((d) => d.isOn).length;
  List<Device> get activeDevices => _devices.where((d) => d.isOn).toList();
  List<String> get rooms =>
      _devices.map((d) => d.room).toSet().toList()..sort();

  List<Device> devicesByRoom(String room) =>
      _devices.where((d) => d.room == room).toList();

  Future<void> fetchDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _deviceRepository.getDevices();
    if (response.success && response.data != null) {
      _devices = response.data!;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDevice(String id) async {
    final idx = _devices.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final previousState = _devices[idx].isOn;
      
      // Optimistic switch
      _devices[idx].isOn = !previousState;
      notifyListeners();

      final response = await _deviceRepository.toggleDevice(id, !previousState);
      if (!response.success) {
        // Rollback on failure
        _devices[idx].isOn = previousState;
        notifyListeners();
      }
    }
  }

  void turnAllOff() {
    for (final d in _devices) {
      if (d.isOn) toggleDevice(d.id);
    }
  }

  void turnAllOn() {
    for (final d in _devices) {
      if (!d.isOn) toggleDevice(d.id);
    }
  }

  Future<void> addDevice(Device device) async {
    final response = await _deviceRepository.addDevice(device);
    if (response.success && response.data != null) {
      _devices.add(response.data!);
      notifyListeners();
    }
  }

  Future<void> removeDevice(String id) async {
    final response = await _deviceRepository.removeDevice(id);
    if (response.success) {
      _devices.removeWhere((d) => d.id == id);
      notifyListeners();
    }
  }
}