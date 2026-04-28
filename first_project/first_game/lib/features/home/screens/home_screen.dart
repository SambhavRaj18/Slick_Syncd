import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../devices/device_provider.dart';
import '../../../routes/app_routes.dart';
import '../widgets/room_selector.dart';
import '../../../shared/widgets/device_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedRoom = 'Living Room';

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(deviceProvider);
    final rooms = ref.read(deviceProvider.notifier).rooms;
    final filteredDevices = devices
        .where((d) => d.room == _selectedRoom)
        .toList();
    final onlineCount = devices.where((d) => d.isOn).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Fancy SliverAppBar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 700),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    AppStrings.appName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.settings,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats Row inside header
                          Row(
                            children: [
                              _HeaderStat(
                                value: '$onlineCount',
                                label: 'Online',
                                icon: Icons.bolt_rounded,
                              ),
                              const SizedBox(width: 16),
                              _HeaderStat(
                                value: '${devices.length}',
                                label: 'Devices',
                                icon: Icons.devices_rounded,
                              ),
                              const SizedBox(width: 16),
                              const _HeaderStat(
                                value: '3',
                                label: 'Rules',
                                icon: Icons.auto_awesome_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),

                // ── Rooms ──────────────────────────────────────────────────
                _SectionTitle(
                  title: 'Rooms',
                  trailing: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.devices),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RoomSelector(
                  rooms: rooms,
                  selectedRoom: _selectedRoom,
                  onRoomSelected: (room) =>
                      setState(() => _selectedRoom = room),
                ),

                const SizedBox(height: 20),

                // ── Device Cards horizontal scroll ─────────────────────────
                if (filteredDevices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: _EmptyDevicesCard(),
                  )
                else
                  SizedBox(
                    height: 186,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredDevices.length,
                      itemBuilder: (context, index) {
                        final device = filteredDevices[index];
                        return FadeInRight(
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(milliseconds: index * 80),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: SizedBox(
                              width: 158,
                              child: DeviceCard(
                                device: device,
                                onToggle: () => ref
                                    .read(deviceProvider.notifier)
                                    .toggleDevice(device.id),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.deviceDetail,
                                  arguments: device.id,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 32),

                // ── Smart Capabilities ─────────────────────────────────────
                const _SectionTitle(title: 'Smart Capabilities'),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _FeatureGrid(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '${AppStrings.goodMorning} 👋';
    if (hour < 17) return '${AppStrings.goodAfternoon} 👋';
    return '${AppStrings.goodEvening} 👋';
  }
}

// ─── Header Stat Chip ─────────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyDevicesCard extends StatelessWidget {
  const _EmptyDevicesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.device_unknown_rounded,
            color: AppColors.textHint,
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'No devices in this room yet.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid ─────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        'Devices',
        Icons.devices_other_rounded,
        const Color(0xFF2196F3),
        AppRoutes.devices,
        'Control & monitor',
      ),
      _Feature(
        'Voice AI',
        Icons.mic_none_rounded,
        const Color(0xFF7C3AED),
        AppRoutes.voiceControl,
        'Smart assistant',
      ),
      _Feature(
        'Gesture AI',
        Icons.pan_tool_outlined,
        const Color(0xFFEC4899),
        AppRoutes.gestureControl,
        'Air controls',
      ),
      _Feature(
        'Dashboard',
        Icons.language_rounded,
        const Color(0xFF00BCD4),
        AppRoutes.webControl,
        'Remote access',
      ),
      _Feature(
        'Automation',
        Icons.bolt_rounded,
        const Color(0xFF10B981),
        AppRoutes.automation,
        'AI smart rules',
      ),
      _Feature(
        'Settings',
        Icons.tune_rounded,
        const Color(0xFF64748B),
        AppRoutes.settings,
        'Preferences',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (ctx, i) => FadeInUp(
        duration: const Duration(milliseconds: 500),
        delay: Duration(milliseconds: 100 + (i * 80)),
        child: _FeatureCard(feature: features[i]),
      ),
    );
  }
}

class _Feature {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String subtitle;

  _Feature(this.title, this.icon, this.color, this.route, this.subtitle);
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        Navigator.pushNamed(context, f.route);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: f.color.withOpacity(0.15), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: f.color.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: f.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(f.icon, color: f.color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    f.subtitle,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
