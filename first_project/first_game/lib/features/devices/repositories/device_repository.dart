import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/models/api_response.dart';
import '../../../core/services/api_client.dart';
import '../models/device_model.dart';
import 'package:firebase_database/firebase_database.dart';


/// Contract for Device operations.
abstract class IDeviceRepository {
  Future<ApiResponse<List<Device>>> getDevices();
  Future<ApiResponse<Device>> addDevice(Device device);
  Future<ApiResponse<void>> toggleDevice(String deviceId, bool isOn);
  Future<ApiResponse<void>> removeDevice(String deviceId);
}

/// Real implementation that communicates with the Slick Sync Flask backend.
class RealDeviceRepository implements IDeviceRepository {
  final ApiClient _apiClient = ApiClient();

  // Mapping Flutter Device IDs to Flask Endpoints
  final Map<String, String> _deviceMapping = {
    'd1': 'rock',
    'd2': 'fan',
    'd3': 'moon',
    'd4': 'dog',
  };

  @override
  Future<ApiResponse<List<Device>>> getDevices() async {
    Map<String, dynamic> data = {};
    try {
      final response = await _apiClient.get('/status');
      if (response.statusCode == 200) {
        data = response.data;
      }
    } catch (e) {
      // Silently ignore connection errors to keep the UI populated
      debugPrint('Backend unreachable: $e');
    }

    final List<Device> devices = [
      Device(id: 'd1', name: 'Rock Light', type: DeviceType.light, isOn: data['rock'] ?? false, room: 'Living Room'),
      Device(id: 'd2', name: 'Ceiling Fan', type: DeviceType.fan, isOn: data['fan'] ?? false, room: 'Bedroom'),
      Device(id: 'd3', name: 'Moon Light', type: DeviceType.light, isOn: data['moon'] ?? false, room: 'Bedroom'),
      Device(id: 'd4', name: 'Dog Light', type: DeviceType.light, isOn: data['dog'] ?? false, room: 'Living Room'),
    ];
    
    return ApiResponse.success(devices);
  }

  @override
  Future<ApiResponse<void>> toggleDevice(String deviceId, bool isOn) async {
    try {
      final endpoint = _deviceMapping[deviceId];
      if (endpoint == null) return ApiResponse.error('Device not mapped to backend');

      final action = isOn ? 'on' : 'off';
      final response = await _apiClient.get('/$endpoint/$action');
      
      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }
      return ApiResponse.error('Failed to toggle device');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Device>> addDevice(Device device) async {
    // Backend is currently static, so we just simulate adding
    return ApiResponse.success(device);
  }

  @override
  Future<ApiResponse<void>> removeDevice(String deviceId) async {
    // Backend is currently static
    return ApiResponse.success(null);
  }
}

/// Firebase implementation that communicates with Firebase Realtime Database.
class FirebaseDeviceRepository implements IDeviceRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://slicksync-afd0d-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref('devices');

  final Map<String, String> _deviceMapping = {
    'd1': 'rock',
    'd2': 'fan',
    'd3': 'moon',
    'd4': 'dog',
  };

  @override
  Future<ApiResponse<List<Device>>> getDevices() async {
    try {
      final snapshot = await _dbRef.get();
      final Map<dynamic, dynamic> data = (snapshot.value as Map? ?? {});
      
      final List<Device> devices = [
        Device(id: 'd1', name: 'Rock Light', type: DeviceType.light, isOn: data['rock'] == 'on', room: 'Living Room'),
        Device(id: 'd2', name: 'Ceiling Fan', type: DeviceType.fan, isOn: data['fan'] == 'on', room: 'Bedroom'),
        Device(id: 'd3', name: 'Moon Light', type: DeviceType.light, isOn: data['moon'] == 'on', room: 'Bedroom'),
        Device(id: 'd4', name: 'Dog Light', type: DeviceType.light, isOn: data['dog'] == 'on', room: 'Living Room'),
      ];
      
      return ApiResponse.success(devices);
    } catch (e) {
      debugPrint('Firebase error: $e');
      // Fallback to offline list if Firebase fails
      return ApiResponse.success([
        Device(id: 'd1', name: 'Rock Light', type: DeviceType.light, isOn: false, room: 'Living Room'),
        Device(id: 'd2', name: 'Ceiling Fan', type: DeviceType.fan, isOn: false, room: 'Bedroom'),
        Device(id: 'd3', name: 'Moon Light', type: DeviceType.light, isOn: false, room: 'Bedroom'),
        Device(id: 'd4', name: 'Dog Light', type: DeviceType.light, isOn: false, room: 'Living Room'),
      ]);
    }
  }

  @override
  Future<ApiResponse<void>> toggleDevice(String deviceId, bool isOn) async {
    try {
      final key = _deviceMapping[deviceId];
      if (key == null) return ApiResponse.error('Device not mapped');

      final action = isOn ? 'on' : 'off';
      await _dbRef.child(key).set(action);
      
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Device>> addDevice(Device device) async => ApiResponse.success(device);

  @override
  Future<ApiResponse<void>> removeDevice(String deviceId) async => ApiResponse.success(null);
}


/// Mock implementation for development without a backend.
class MockDeviceRepository implements IDeviceRepository {
  final List<Device> _mockDevices = [
    Device(id: 'd1', name: 'Living Room Light (Mock)', type: DeviceType.light, isOn: true, room: 'Living Room'),
    Device(id: 'd2', name: 'Ceiling Fan (Mock)', type: DeviceType.fan, isOn: false, room: 'Bedroom'),
    Device(id: 'd3', name: 'Air Conditioner (Mock)', type: DeviceType.ac, isOn: true, room: 'Bedroom'),
    Device(id: 'd4', name: 'Smart TV (Mock)', type: DeviceType.tv, isOn: false, room: 'Living Room'),
  ];

  @override
  Future<ApiResponse<List<Device>>> getDevices() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ApiResponse.success(List.from(_mockDevices));
  }

  @override
  Future<ApiResponse<Device>> addDevice(Device device) async {
    _mockDevices.add(device);
    return ApiResponse.success(device);
  }

  @override
  Future<ApiResponse<void>> toggleDevice(String deviceId, bool isOn) async {
    final index = _mockDevices.indexWhere((d) => d.id == deviceId);
    if (index != -1) {
      _mockDevices[index].isOn = isOn;
      return ApiResponse.success(null);
    }
    return ApiResponse.error('Device not found');
  }

  @override
  Future<ApiResponse<void>> removeDevice(String deviceId) async {
    _mockDevices.removeWhere((d) => d.id == deviceId);
    return ApiResponse.success(null);
  }
}
