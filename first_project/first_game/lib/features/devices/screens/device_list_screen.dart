import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:first_game/core/constants/app_colors.dart';
import 'package:first_game/core/constants/app_strings.dart';
import 'package:first_game/shared/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:first_game/routes/app_routes.dart';
import '../device_provider.dart';

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceProvider);
    final notifier = ref.read(deviceProvider.notifier);
    final onlineCount = devices.where((d) => d.isOn).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.allDevices),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            onSelected: (v) {
              if (v == 'on') {
                for (final d in devices) {
                  if (!d.isOn) notifier.toggleDevice(d.id);
                }
              } else {
                for (final d in devices) {
                  if (d.isOn) notifier.toggleDevice(d.id);
                }
              }
            },
            itemBuilder: (_) => [
              _menuItem('on', 'Turn All ON', Icons.power_settings_new,
                  AppColors.success),
              _menuItem(
                  'off', 'Turn All OFF', Icons.power_off, AppColors.error),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tune_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 4),
                    Text('Control',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _StatsBar(
                total: devices.length, online: onlineCount),
          ),
          const SizedBox(height: 20),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: devices.length,
              itemBuilder: (ctx, i) {
                final device = devices[i];
                return DeviceCard(
                  device: device,
                  onToggle: () => notifier.toggleDevice(device.id),
                  onTap: () => Navigator.pushNamed(
                    ctx,
                    '/device-detail',
                    arguments: device.id,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addDevice),
        backgroundColor: AppColors.primary,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Device',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, String label, IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

// ─── Stats Bar ────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final int total;
  final int online;

  const _StatsBar({required this.total, required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Total', total.toString(), Icons.devices_rounded,
              AppColors.primary),
          _divider(),
          _stat('Online', online.toString(), Icons.wifi_rounded,
              AppColors.success),
          _divider(),
          _stat('Offline', (total - online).toString(),
              Icons.wifi_off_rounded, AppColors.error),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _divider() => Container(
        height: 50,
        width: 1,
        color: AppColors.borderLight,
      );
}
