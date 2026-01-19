import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_manager.dart';
import '../domain/settings_provider.dart';

/// Settings screen for configuring app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final HapticManager _hapticManager = HapticManager();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Haptic Feedback Section
          _buildSection(
            title: 'Haptic Feedback',
            icon: Icons.vibration,
            children: [
              SwitchListTile(
                title: Text(
                  'Enable Haptic',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Vibration feedback for breathing',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: settings.hapticEnabled,
                onChanged: (value) async {
                  await _hapticManager.eventTap();
                  settingsNotifier.toggleHaptic();
                },
                activeTrackColor: AppColors.primary.withOpacity( 0.5),
                thumbColor: WidgetStateProperty.all(AppColors.primary),
              ),
              if (settings.hapticEnabled) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Intensity',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${(settings.hapticIntensity * 100).toInt()}%',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.hapticIntensity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        onChanged: (value) async {
                          await _hapticManager.eventTap();
                          settingsNotifier.updateHapticIntensity(value);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Timer Section
          _buildSection(
            title: 'Timer',
            icon: Icons.timer_outlined,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Duration',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildDurationChip(
                          label: '1 min',
                          value: 60,
                          selected: settings.defaultDuration == 60,
                          onTap: () async {
                            await _hapticManager.eventTap();
                            settingsNotifier.updateDefaultDuration(60);
                          },
                        ),
                        _buildDurationChip(
                          label: '3 min',
                          value: 180,
                          selected: settings.defaultDuration == 180,
                          onTap: () async {
                            await _hapticManager.eventTap();
                            settingsNotifier.updateDefaultDuration(180);
                          },
                        ),
                        _buildDurationChip(
                          label: '5 min',
                          value: 300,
                          selected: settings.defaultDuration == 300,
                          onTap: () async {
                            await _hapticManager.eventTap();
                            settingsNotifier.updateDefaultDuration(300);
                          },
                        ),
                        _buildDurationChip(
                          label: '10 min',
                          value: 600,
                          selected: settings.defaultDuration == 600,
                          onTap: () async {
                            await _hapticManager.eventTap();
                            settingsNotifier.updateDefaultDuration(600);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Animation Section
          _buildSection(
            title: 'Animation',
            icon: Icons.animation,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Breathing Speed',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${settings.animationSpeed}x',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.animationSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 6,
                      onChanged: (value) async {
                        await _hapticManager.eventTap();
                        settingsNotifier.updateAnimationSpeed(value);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sound Section
          _buildSection(
            title: 'Sound',
            icon: Icons.volume_up,
            children: [
              SwitchListTile(
                title: Text(
                  'Enable Sound',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Audio feedback (Coming soon)',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                value: settings.soundEnabled,
                onChanged: null, // Disabled for now
                activeTrackColor: AppColors.primary.withOpacity( 0.5),
                thumbColor: WidgetStateProperty.all(AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Reset Section
          _buildSection(
            title: 'Reset',
            icon: Icons.refresh,
            children: [
              ListTile(
                title: Text(
                  'Reset to Defaults',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: AppColors.error,
                  ),
                ),
                subtitle: Text(
                  'Restore all settings to default values',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                leading: const Icon(
                  Icons.restore,
                  color: AppColors.error,
                ),
                onTap: () async {
                  // Capture context before async gap
                  final context = this.context;
                  
                  await _hapticManager.warning();
                  if (!mounted) return;
                  
                  // Use captured context for showDialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text(
                        'Reset Settings?',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      content: Text(
                        'This will restore all settings to their default values.',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Reset',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await _hapticManager.completion();
                    settingsNotifier.resetToDefaults();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Settings reset to defaults',
                            style: GoogleFonts.roboto(),
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDurationChip({
    required String label,
    required int value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: selected 
          ? AppColors.primary.withOpacity( 0.2)
          : AppColors.surface,
      labelStyle: GoogleFonts.roboto(
        fontSize: 14,
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.textSecondary.withOpacity( 0.3),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
