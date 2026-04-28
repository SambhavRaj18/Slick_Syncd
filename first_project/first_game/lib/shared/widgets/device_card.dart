import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/devices/models/device_model.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const DeviceCard({
    super.key,
    required this.device,
    this.onToggle,
    this.onTap,
  });

  Color get _deviceColor {
    switch (device.type) {
      case DeviceType.light:
        return const Color(0xFF2196F3);
      case DeviceType.fan:
        return const Color(0xFF00BCD4);
      case DeviceType.ac:
        return const Color(0xFF1565C0);
      case DeviceType.tv:
        return const Color(0xFF7B1FA2);
      case DeviceType.camera:
        return const Color(0xFF00838F);
      case DeviceType.lock:
        return const Color(0xFF1B5E20);
      case DeviceType.speaker:
        return const Color(0xFF4527A0);
      case DeviceType.thermostat:
        return const Color(0xFFF57C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'device_${device.id}',
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: device.isOn
                  ? _deviceColor.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: device.isOn
                    ? _deviceColor.withValues(alpha: 0.25)
                    : AppColors.border,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: device.isOn
                      ? _deviceColor.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: device.isOn ? 18 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Switch Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: device.isOn
                            ? _deviceColor.withValues(alpha: 0.12)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        device.icon,
                        color: device.isOn ? _deviceColor : AppColors.textHint,
                        size: 22,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: device.isOn,
                        onChanged: onToggle != null ? (_) => onToggle!() : null,
                        activeThumbColor: Colors.white,
                        activeTrackColor: _deviceColor,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.border,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Device name
                Text(
                  device.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  device.room,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: device.isOn
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: device.isOn
                              ? AppColors.success
                              : AppColors.textHint,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        device.isOn ? 'Active' : 'Off',
                        style: TextStyle(
                          color: device.isOn
                              ? AppColors.success
                              : AppColors.textHint,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
