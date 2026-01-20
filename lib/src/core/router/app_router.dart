import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../../features/home/presentation/breathing_animation_widget.dart';
import '../../features/home/presentation/breathing_circle_painter.dart';
import '../../features/home/domain/breathe_timer_provider_phase2.dart';
import '../utils/haptic_manager.dart';

/// Route paths
class AppRoutes {
  static const String home = '/';
  static const String settings = '/settings';
  static const String history = '/history';
}

/// App router configuration
class AppRouter {
  /// Create GoRouter instance
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const Phase2HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const Phase2SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.history,
          name: 'history',
          builder: (context, state) => const Phase2HistoryScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Page not found: ${state.uri}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter();
});


// ============================================================
// Phase 2: Animation & Haptic Feedback
// ============================================================

/// Phase 2 Home Screen - With breathing animation and haptic feedback
class Phase2HomeScreen extends ConsumerWidget {
  const Phase2HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(breathingTimerProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Breathing animation circle (now animated!)
          const BreathingAnimationWidget(
            color: AppColors.primary,
            baseRadius: 80.0,
            maxRadius: 150.0,
            duration: Duration(seconds: 4),
          ),
          
          // Navigation buttons (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Row(
              children: [
                // History button
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push(AppRoutes.history);
                  },
                  icon: const Icon(Icons.history_rounded, size: 28),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                // Settings button
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.push(AppRoutes.settings);
                  },
                  icon: const Icon(Icons.settings_rounded, size: 28),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // App branding (top center)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Resonate',
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visual Haptic Focus & Breath',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          
          // Timer control panel (bottom)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 24,
            right: 24,
            child: const Phase2TimerControlWidget(),
          ),
          
          // Phase indicator (bottom left)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 8,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '✅ Phase 2: Animation',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phase 2 Timer Control Widget
class Phase2TimerControlWidget extends ConsumerStatefulWidget {
  const Phase2TimerControlWidget({super.key});

  @override
  ConsumerState<Phase2TimerControlWidget> createState() => _Phase2TimerControlWidgetState();
}

class _Phase2TimerControlWidgetState extends ConsumerState<Phase2TimerControlWidget> {
  final HapticManager _hapticManager = HapticManager();
  int _selectedDuration = 60;

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
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
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
                  selected: _selectedDuration == 60,
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    setState(() => _selectedDuration = 60);
                    timerNotifier.setDuration(60);
                  },
                ),
                _buildDurationButton(
                  duration: 180,
                  label: '3m',
                  selected: _selectedDuration == 180,
                  onPressed: () async {
                    await _hapticManager.eventTap();
                    setState(() => _selectedDuration = 180);
                    timerNotifier.setDuration(180);
                  },
                ),
                _buildDurationButton(
                  duration: 300,
                  label: '5m',
                  selected: _selectedDuration == 300,
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
        backgroundColor: selected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
        foregroundColor: selected ? AppColors.primary : AppColors.textSecondary,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
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

/// Phase 2 Settings Screen - Placeholder
class Phase2SettingsScreen extends StatelessWidget {
  const Phase2SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Settings',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in Phase 3',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phase 2 History Screen - Placeholder
class Phase2HistoryScreen extends StatelessWidget {
  const Phase2HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Text(
          'History',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'History',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in Phase 3',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
