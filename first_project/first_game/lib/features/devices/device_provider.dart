import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import 'models/device_model.dart';
import 'repositories/device_repository.dart';


final deviceProvider = StateNotifierProvider<DeviceNotifier, List<Device>>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return DeviceNotifier(repository);
});

class DeviceNotifier extends StateNotifier<List<Device>> {
  final IDeviceRepository _deviceRepository;

  DeviceNotifier(this._deviceRepository) : super([]) {
    fetchDevices();
  }

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  int get onlineCount => state.where((d) => d.isOn).length;
  List<String> get rooms => state.map((d) => d.room).toSet().toList()..sort();

  Future<void> fetchDevices() async {
    _isLoading = true;
    _error = null;
    
    final response = await _deviceRepository.getDevices();
    if (response.success && response.data != null) {
      state = response.data!;
    } else {
      _error = response.message;
    }
    
    _isLoading = false;
  }

  Future<void> addDevice(Device device) async {
    _isLoading = true;
    _error = null;
    state = [...state, device]; // Optimistic update

    final response = await _deviceRepository.addDevice(device);
    if (!response.success) {
      _error = response.message;
      state = state.where((d) => d.id != device.id).toList(); // Rollback
    }
    
    _isLoading = false;
  }

  Future<void> toggleDevice(String id) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index != -1) {
      final previousState = state[index].isOn;
      
      // Optimistic update
      state = [
        for (final device in state)
          if (device.id == id) device.copyWith(isOn: !previousState) else device,
      ];

      final response = await _deviceRepository.toggleDevice(id, !previousState);
      if (!response.success) {
        // Rollback
        state = [
          for (final device in state)
            if (device.id == id) device.copyWith(isOn: previousState) else device,
        ];
      }
    }
  }

  void updateDeviceLocally(Device updatedDevice) {
    state = [
      for (final device in state)
        if (device.id == updatedDevice.id) updatedDevice else device,
    ];
  }

  /// Update a single attribute of a device locally (no backend call needed for frontend-only).
  void updateAttribute(
    String id, {
    double? brightness,
    double? temperature,
    int? speed,
    Color? color,
  }) {
    state = [
      for (final device in state)
        if (device.id == id)
          device.copyWith(
            brightness: brightness,
            temperature: temperature,
            speed: speed,
            color: color,
          )
        else
          device,
    ];
  }
}

