import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:first_game/core/constants/app_colors.dart';
import 'package:first_game/core/constants/app_strings.dart';
import 'package:first_game/shared/widgets/custom_button.dart';
import '../device_provider.dart';
import '../models/device_model.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  DeviceType _selectedType = DeviceType.light;

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final newDevice = Device(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        room: _roomController.text.trim(),
        isOn: false,
      );

      await ref.read(deviceProvider.notifier).addDevice(newDevice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.deviceAddedSuccess),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.addDevice),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Device Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: AppStrings.deviceName,
                hint: 'e.g. Living Room Lamp',
                icon: Icons.edit_rounded,
                validator: (v) => v == null || v.isEmpty ? AppStrings.emptyField : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _roomController,
                label: AppStrings.deviceRoom,
                hint: 'e.g. Living Room',
                icon: Icons.room_rounded,
                validator: (v) => v == null || v.isEmpty ? AppStrings.emptyField : null,
              ),
              const SizedBox(height: 32),
              _sectionTitle('Select Device Type'),
              const SizedBox(height: 16),
              _buildTypeGrid(),
              const SizedBox(height: 48),
              CustomButton(
                label: AppStrings.saveDevice,
                onPressed: _submit,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: DeviceType.values.length,
      itemBuilder: (context, index) {
        final type = DeviceType.values[index];
        final isSelected = _selectedType == type;
        
        final icon = _getIconForType(type);
        final label = _getLabelForType(type);

        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(DeviceType type) {
    switch (type) {
      case DeviceType.light: return Icons.lightbulb_outline;
      case DeviceType.fan: return Icons.air;
      case DeviceType.ac: return Icons.ac_unit;
      case DeviceType.tv: return Icons.tv;
      case DeviceType.camera: return Icons.videocam_outlined;
      case DeviceType.lock: return Icons.lock_outline;
      case DeviceType.speaker: return Icons.speaker_outlined;
      case DeviceType.thermostat: return Icons.thermostat;
    }
  }

  String _getLabelForType(DeviceType type) {
    switch (type) {
      case DeviceType.light: return 'Light';
      case DeviceType.fan: return 'Fan';
      case DeviceType.ac: return 'AC';
      case DeviceType.tv: return 'TV';
      case DeviceType.camera: return 'Camera';
      case DeviceType.lock: return 'Lock';
      case DeviceType.speaker: return 'Speaker';
      case DeviceType.thermostat: return 'Temp';
    }
  }
}
