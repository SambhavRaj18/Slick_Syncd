import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'voice_controller.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<VoiceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            _buildAppBar(context, ctrl),

            // ── Mic Hero Area ─────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAIWaveform(ctrl),
                      const SizedBox(height: 28),
                      Text(
                        ctrl.isListening
                            ? AppStrings.listening
                            : ctrl.isProcessing
                                ? AppStrings.processing
                                : AppStrings.tapToSpeak,
                        style: TextStyle(
                          color: ctrl.isListening
                              ? const Color(0xFFB2EBF2)
                              : Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (ctrl.currentText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            '"${ctrl.currentText}"',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── History Section ───────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Commands',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          if (ctrl.history.isNotEmpty)
                            TextButton.icon(
                              onPressed: ctrl.clearHistory,
                              icon: const Icon(Icons.delete_sweep_outlined,
                                  size: 16),
                              label: const Text('Clear'),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error),
                            )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ctrl.history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.history_rounded,
                                        color: AppColors.primary,
                                        size: 36),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    AppStrings.noVoiceCommands,
                                    style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 0, 20, 16),
                              itemCount: ctrl.history.length,
                              itemBuilder: (_, i) => FadeInUp(
                                duration:
                                    const Duration(milliseconds: 400),
                                delay: Duration(milliseconds: i * 80),
                                child:
                                    _CommandTile(command: ctrl.history[i]),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, VoiceController ctrl) {
    return Container(
      color: AppColors.primary,
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Voice AI Assistant',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAIWaveform(VoiceController ctrl) {
    return GestureDetector(
      onTap: ctrl.isListening || ctrl.isProcessing
          ? null
          : () => ctrl.startListening(),
      child: AnimatedBuilder(
        animation: _waveCtrl,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (ctrl.isListening)
                CustomPaint(
                  size: const Size(200, 200),
                  painter: WavePainter(
                    animationValue: _waveCtrl.value,
                    color: Colors.white,
                  ),
                ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ctrl.isListening
                      ? Colors.white
                      : Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Icon(
                  ctrl.isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  color: ctrl.isListening
                      ? AppColors.primary
                      : Colors.white,
                  size: 42,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Wave Painter ─────────────────────────────────────────────────────────────
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final value = (animationValue + i / 3) % 1.0;
      final radius = (size.width / 2) * value;
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint..color = color.withOpacity((1.0 - value) * 0.4),
      );
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

// ─── Command Tile ─────────────────────────────────────────────────────────────
class _CommandTile extends StatelessWidget {
  final dynamic command;
  const _CommandTile({required this.command});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline_rounded,
                    color: AppColors.primary, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  command.text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    command.response,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
