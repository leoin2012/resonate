import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_manager.dart';
import '../../home/domain/breathe_timer_provider.dart';

/// Timer control widget for breathing session
class TimerControlWidget extends ConsumerStatefulWidget {
  const TimerControlWidget({super.key});

  @override
  ConsumerState<TimerControlWidget> createState() => _TimerControlState();
}

class _TimerControlState extends ConsumerState<TimerControlWidget> {
  final HapticManager _hapticManager = HapticManager();
  int _selectedDuration = 60; // Default 1 minute

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(breathingTimerProvider);
    final timerNotifier = ref.read(breathingTimerProvider.notifier);

    // Format time as MM:SS
    final remaining = timerState.remaining;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    final timeDisplay = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time display
          Text(
            timeDisplay,
            style: GoogleFonts.orbitron(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timerState.progress,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 24),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!timerState.isRunning) ...[
                // Start button
                _buildControlButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Start',
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    timerNotifier.start();
                  },
                ),
                // Duration selector
                _buildDurationButton(
                  duration: 60,
                  label: '1m',
                  selected: _selectedDuration == 60 && !timerState.isRunning,
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    setState(() => _selectedDuration = 60);
                    timerNotifier.setDuration(60);
                  },
                ),
                _buildDurationButton(
                  duration: 180,
                  label: '3m',
                  selected: _selectedDuration == 180 && !timerState.isRunning,
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    setState(() => _selectedDuration = 180);
                    timerNotifier.setDuration(180);
                  },
                ),
                _buildDurationButton(
                  duration: 300,
                  label: '5m',
                  selected: _selectedDuration == 300 && !timerState.isRunning,
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    setState(() => _selectedDuration = 300);
                    timerNotifier.setDuration(300);
                  },
                ),
              ] else ...[
                // Pause button
                _buildControlButton(
                  icon: Icons.pause_rounded,
                  label: 'Pause',
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    timerNotifier.pause();
                  },
                ),
                // Reset button
                _buildControlButton(
                  icon: Icons.refresh_rounded,
                  label: 'Reset',
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    timerNotifier.reset();
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDurationButton({
    required int duration,
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
        foregroundColor: selected ? AppColors.primary : AppColors.textSecondary,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
      ),
    );
  }
}
