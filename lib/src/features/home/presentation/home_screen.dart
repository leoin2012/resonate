import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'breathing_animation_widget.dart';
import 'timer_control_widget.dart';

/// Home screen with breathing animation, timer controls and app branding
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Breathing animation in the background
          const Positioned.fill(
            child: BreathingAnimationWidget(
              color: AppColors.primary,
              baseRadius: 80.0,
              maxRadius: 150.0,
              duration: Duration(seconds: 4),
            ),
          ),
          // Settings button (top right)
          Positioned(
            top: 40,
            right: 16,
            child: Row(
              children: [
                // History button
                IconButton(
                  onPressed: () {
                    context.push('/history');
                  },
                  icon: const Icon(
                    Icons.history_rounded,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                // Settings button
                IconButton(
                  onPressed: () {
                    context.push('/settings');
                  },
                  icon: const Icon(
                    Icons.settings_rounded,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // App branding centered on top
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App name display
                Text(
                  'Resonate',
                  style: GoogleFonts.orbitron(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Visual Haptic Focus & Breath',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 40),
                // Timer control widget
                const TimerControlWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
