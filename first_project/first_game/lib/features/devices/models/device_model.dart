import 'package:flutter/material.dart';

enum DeviceType { light, fan, ac, tv, camera, lock, speaker, thermostat }

class Device {
  final String id;
  String name;
  DeviceType type;
  bool isOn;
  String room;
  // Advanced Attributes
  double brightness; // 0.0 to 1.0
  double temperature; // 16.0 to 30.0 °C
  int speed; // 0 to 3
  Color color;

  Device({
    required this.id,
    required this.name,
    this.type = DeviceType.light,
    this.isOn = false,
    this.room = 'Living Room',
    this.brightness = 0.8,
    this.temperature = 22.0,
    this.speed = 1,
    this.color = Colors.white,
  });

  IconData get icon {
    switch (type) {
      case DeviceType.light:     return Icons.lightbulb_outline;
      case DeviceType.fan:       return Icons.air;
      case DeviceType.ac:        return Icons.ac_unit;
      case DeviceType.tv:        return Icons.tv;
      case DeviceType.camera:    return Icons.videocam_outlined;
      case DeviceType.lock:      return Icons.lock_outline;
      case DeviceType.speaker:   return Icons.speaker_outlined;
      case DeviceType.thermostat:return Icons.thermostat;
    }
  }

  String get typeLabel {
    switch (type) {
      case DeviceType.light:     return 'Light';
      case DeviceType.fan:       return 'Fan';
      case DeviceType.ac:        return 'Air Conditioner';
      case DeviceType.tv:        return 'Television';
      case DeviceType.camera:    return 'Camera';
      case DeviceType.lock:      return 'Smart Lock';
      case DeviceType.speaker:   return 'Speaker';
      case DeviceType.thermostat:return 'Thermostat';
    }
  }

  Device copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOn,
    String? room,
    double? brightness,
    double? temperature,
    int? speed,
    Color? color,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      room: room ?? this.room,
      brightness: brightness ?? this.brightness,
      temperature: temperature ?? this.temperature,
      speed: speed ?? this.speed,
      color: color ?? this.color,
    );
  }
}