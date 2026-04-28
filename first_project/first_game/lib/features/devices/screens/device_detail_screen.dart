import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:first_game/core/constants/app_colors.dart';
import 'package:first_game/shared/widgets/circular_slider.dart';
import '../device_provider.dart';
import '../models/device_model.dart';

class DeviceDetailScreen extends ConsumerWidget {
  final String? deviceId;
  const DeviceDetailScreen({super.key, this.deviceId});

  Color _deviceColor(DeviceType type) {
    switch (type) {
      case DeviceType.light:     return const Color(0xFF2196F3);
      case DeviceType.fan:       return const Color(0xFF00BCD4);
      case DeviceType.ac:        return const Color(0xFF1565C0);
      case DeviceType.tv:        return const Color(0xFF7B1FA2);
      case DeviceType.camera:    return const Color(0xFF00838F);
      case DeviceType.lock:      return const Color(0xFF1B5E20);
      case DeviceType.speaker:   return const Color(0xFF4527A0);
      case DeviceType.thermostat:return const Color(0xFFF57C00);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceProvider);
    final device = devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => devices[0],
    );
    final notifier = ref.read(deviceProvider.notifier);
    final color = _deviceColor(device.type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Hero icon
                      Hero(
                        tag: 'device_${device.id}',
                        child: FadeInDown(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2),
                            ),
                            child: Icon(device.icon,
                                size: 42, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        device.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Online/Offline badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: device.isOn
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          device.isOn
                              ? '● Online — ${device.room}'
                              : '○ Offline — ${device.room}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Body Content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  // Controls
                  _buildMainControls(device, notifier, color),
                  const SizedBox(height: 24),
                  // Stats
                  _buildAdvancedStats(device, color),
                  const SizedBox(height: 24),
                  // Power Button
                  _buildPowerToggle(device, notifier, color),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls(
      Device device, DeviceNotifier notifier, Color color) {
    if (!device.isOn) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.power_off_rounded,
                size: 42, color: AppColors.textHint.withOpacity(0.5)),
            const SizedBox(height: 12),
            const Text(
              'Device is powered off',
              style: TextStyle(color: AppColors.textHint, fontSize: 15),
            ),
          ],
        ),
      );
    }

    switch (device.type) {
      case DeviceType.ac:
      case DeviceType.thermostat:
        return FadeInUp(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: CircularSlider(
              value: device.temperature,
              min: 16,
              max: 30,
              label: 'TEMPERATURE',
              color: color,
              onChanged: (v) =>
                  notifier.updateAttribute(device.id, temperature: v),
            ),
          ),
        );
      case DeviceType.light:
        return _buildLightControls(device, notifier, color);
      case DeviceType.fan:
        return _buildFanControls(device, notifier, color);
      default:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_rounded,
                  color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Basic Switch Control',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildLightControls(
      Device device, DeviceNotifier notifier, Color color) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brightness
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('BRIGHTNESS',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.5)),
                Text('${(device.brightness * 100).toInt()}%',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.15),
                thumbColor: color,
                overlayColor: color.withOpacity(0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: device.brightness,
                onChanged: (v) =>
                    notifier.updateAttribute(device.id, brightness: v),
              ),
            ),
            const SizedBox(height: 20),
            const Text('SCENE COLOR',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _colorNode(Colors.white, device, notifier),
                _colorNode(Colors.orangeAccent, device, notifier),
                _colorNode(Colors.blueAccent, device, notifier),
                _colorNode(Colors.purpleAccent, device, notifier),
                _colorNode(Colors.greenAccent, device, notifier),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorNode(Color color, Device device, DeviceNotifier notifier) {
    final isSelected = device.color == color;
    return GestureDetector(
      onTap: () => notifier.updateAttribute(device.id, color: color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 3)
              : Border.all(color: AppColors.border, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2)
                ]
              : [],
        ),
        child: isSelected
            ? Icon(Icons.check_rounded,
                color: color == Colors.white ? AppColors.primary : Colors.white,
                size: 18)
            : null,
      ),
    );
  }

  Widget _buildFanControls(
      Device device, DeviceNotifier notifier, Color color) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FAN SPEED',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                final isSelected = device.speed == index;
                final labels = ['Off', '1', '2', '3'];
                return GestureDetector(
                  onTap: () =>
                      notifier.updateAttribute(device.id, speed: index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 70,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedStats(Device device, Color color) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Device Info',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const SizedBox(height: 16),
            _statRow(Icons.timer_outlined, 'Usage Today', '4.2 Hrs', color),
            const Divider(height: 24, color: AppColors.borderLight),
            _statRow(Icons.bolt_rounded, 'Energy', '1.8 kWh', color),
            const Divider(height: 24, color: AppColors.borderLight),
            _statRow(
                Icons.history_rounded, 'Last Active', '12 mins ago', color),
          ],
        ),
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildPowerToggle(
      Device device, DeviceNotifier notifier, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: () => notifier.toggleDevice(device.id),
        icon: Icon(
          device.isOn ? Icons.power_off_rounded : Icons.power_settings_new,
          size: 22,
        ),
        label: Text(
          device.isOn ? 'Turn Off Device' : 'Turn On Device',
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.2),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: device.isOn ? AppColors.error : AppColors.success,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          shadowColor: (device.isOn ? AppColors.error : AppColors.success)
              .withOpacity(0.3),
        ),
      ),
    );
  }
}
