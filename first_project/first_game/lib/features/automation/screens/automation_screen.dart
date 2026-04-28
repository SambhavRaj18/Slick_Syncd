import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../automation_controller.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AutomationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.automation),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderLight),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addRule,
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      body: ctrl.isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text('Loading rules…',
                      style: TextStyle(
                          color: AppColors.textHint, fontSize: 14)),
                ],
              ),
            )
          : ctrl.rules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.primary, size: 40),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Rules Yet',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(AppStrings.noRules,
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 14)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(AppStrings.addRule),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: ctrl.rules.length,
                  itemBuilder: (_, i) {
                    final rule = ctrl.rules[i];
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: i * 80),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RuleCard(
                          rule: rule,
                          onToggle: () => context
                              .read<AutomationController>()
                              .toggleRule(rule.id),
                          onDelete: () => context
                              .read<AutomationController>()
                              .removeRule(rule.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ─── Rule Card ────────────────────────────────────────────────────────────────
class _RuleCard extends StatelessWidget {
  final dynamic rule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _RuleCard({
    required this.rule,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = rule.isEnabled as bool;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: enabled
                        ? AppColors.primarySurface
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: enabled ? AppColors.primary : AppColors.textHint,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Text(
                    rule.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Toggle
                Switch(
                  value: enabled,
                  onChanged: (_) => onToggle(),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.border,
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  onPressed: onDelete,
                  splashRadius: 20,
                ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 1, color: AppColors.borderLight),
          // Info rows
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                _InfoRow(
                    icon: Icons.bolt_rounded,
                    label: 'Trigger',
                    value: rule.trigger,
                    color: const Color(0xFFF57C00)),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: Icons.filter_alt_rounded,
                    label: 'Condition',
                    value: rule.condition,
                    color: const Color(0xFF7C3AED)),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: Icons.play_circle_rounded,
                    label: 'Action',
                    value: rule.action,
                    color: AppColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
