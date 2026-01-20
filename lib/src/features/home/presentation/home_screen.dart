import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../domain/breathe_timer_provider.dart';
import 'breathing_animation_widget.dart';

/// Home screen with breathing animation and timer controls
/// Phase 2 + Phase 3: Full functionality with haptics and data persistence
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Available duration options in seconds
  final List<int> _durationOptions = [60, 180, 300]; // 1m, 3m, 5m

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(breathingTimerProvider);
    final timerNotifier = ref.read(breathingTimerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with title and navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // History button
                  IconButton(
                    icon: const Icon(Icons.history_rounded),
                    color: Colors.white.withOpacity(0.7),
                    onPressed: () => context.push(AppRoutes.history),
                  ),
                  // Settings button
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    color: Colors.white.withOpacity(0.7),
                    onPressed: () => context.push(AppRoutes.settings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'RESONATE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timerState.isRunning ? 'Breathe...' : 'Ready',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 2.0,
              ),
            ),

            // Breathing animation (expanded to fill space)
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Breathing circle animation
                    const BreathingAnimationWidget(
                      color: Color(0xFF00FFFF),
                      baseRadius: 80.0,
                      maxRadius: 150.0,
                      duration: Duration(seconds: 4),
                    ),

                    // Timer display overlay
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Remaining time
                        Text(
                          _formatTime(timerState.remaining),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Progress percentage
                        Text(
                          '${(timerState.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Cycle count
                        Text(
                          '${timerState.cycleCount} cycles',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF00FFFF).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Duration selector (only show when not running)
            if (!timerState.isRunning && timerState.elapsed == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _durationOptions.map((seconds) {
                    final isSelected = timerState.duration == seconds;
                    return GestureDetector(
                      onTap: () => timerNotifier.setDuration(seconds),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00FFFF).withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00FFFF)
                                : Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _formatDurationLabel(seconds),
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected
                                ? const Color(0xFF00FFFF)
                                : Colors.white.withOpacity(0.7),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 32),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset button (show when has progress)
                if (timerState.elapsed > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _buildControlButton(
                      icon: Icons.refresh,
                      label: 'Reset',
                      onTap: () => timerNotifier.reset(),
                      isPrimary: false,
                    ),
                  ),

                // Main play/pause button
                _buildControlButton(
                  icon: timerState.isRunning ? Icons.pause : Icons.play_arrow,
                  label: timerState.isRunning ? 'Pause' : 'Start',
                  onTap: () {
                    if (timerState.isRunning) {
                      timerNotifier.pause();
                    } else {
                      timerNotifier.start();
                    }
                  },
                  isPrimary: true,
                ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  /// Build a control button
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 72 : 56,
            height: isPrimary ? 72 : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary
                  ? const Color(0xFF00FFFF)
                  : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: isPrimary
                    ? const Color(0xFF00FFFF)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: isPrimary ? 36 : 28,
              color: isPrimary ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Format seconds to MM:SS
  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Format duration label
  String _formatDurationLabel(int seconds) {
    final mins = seconds ~/ 60;
    return '${mins}m';
  }
}
