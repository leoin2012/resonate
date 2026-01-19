import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_manager.dart';
import '../../../data/models/breathing_session.dart';
import '../../../data/repositories/session_repository.dart';
import '../domain/history_provider.dart';

/// History screen showing breathing session records and statistics
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final HapticManager _hapticManager = HapticManager();
  int _selectedPeriod = 7; // Default to last 7 days

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).loadAll(days: _selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Period selector
          _buildPeriodSelector(),
          const SizedBox(width: 8),
          // Clear all button
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: historyState.sessions.isEmpty
                ? null
                : () => _showClearAllDialog(),
            color: AppColors.textSecondary,
          ),
        ],
      ),
      body: historyState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : historyState.error != null
              ? _buildErrorWidget(historyState.error!)
              : historyState.sessions.isEmpty
                  ? _buildEmptyWidget()
                  : _buildContent(historyState),
    );
  }

  Widget _buildPeriodSelector() {
    return PopupMenuButton<int>(
      initialValue: _selectedPeriod,
      icon: Icon(
        Icons.date_range_rounded,
        color: AppColors.textSecondary,
      ),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (period) async {
        await _hapticManager.eventTap();
        setState(() {
          _selectedPeriod = period;
        });
        ref.read(historyProvider.notifier).loadAll(days: period);
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem(1, 'Today'),
        _buildPopupMenuItem(7, 'Last 7 days'),
        _buildPopupMenuItem(30, 'Last 30 days'),
        _buildPopupMenuItem(90, 'Last 90 days'),
        _buildPopupMenuItem(0, 'All time'),
      ],
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(int value, String label) {
    return PopupMenuItem<int>(
      value: value,
      child: Text(
        label,
        style: GoogleFonts.roboto(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading history',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(historyProvider.notifier).loadAll(days: _selectedPeriod);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppColors.textSecondary.withOpacity( 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No sessions yet',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a breathing session to track your progress',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HistoryState state) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        await ref.read(historyProvider.notifier).loadAll(days: _selectedPeriod);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics cards
            if (state.stats != null) _buildStatsCards(state.stats!),
            const SizedBox(height: 24),
            // Sessions list
            _buildSessionsList(state.sessions),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(SessionStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sessions',
                '${stats.totalSessions}',
                Icons.event_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completed',
                '${stats.completedSessions}',
                Icons.check_circle_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Time',
                stats.formattedTotalDuration,
                Icons.timer_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Duration',
                '${stats.averageDuration ~/ 60}m',
                Icons.schedule_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completion Rate',
                '${(stats.completionRate * 100).toInt()}%',
                Icons.percent_rounded,
                color: stats.completionRate >= 0.8
                    ? AppColors.success
                    : stats.completionRate >= 0.5
                        ? AppColors.primary
                        : AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Completion',
                '${(stats.averageCompletion * 100).toInt()}%',
                Icons.speed_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    final cardColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: cardColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cardColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(List<BreathingSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sessions',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildSessionCard(sessions[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSessionCard(BreathingSession session) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: session.isCompleted
              ? AppColors.success.withOpacity( 0.3)
              : AppColors.primary.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    session.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.timer_rounded,
                    color: session.isCompleted
                        ? AppColors.success
                        : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(session.startTime),
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () => _showDeleteDialog(session),
                color: AppColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                timeFormat.format(session.startTime),
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.formattedDuration,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${session.cycleCount} cycles',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: session.completionPercentage,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                session.isCompleted
                    ? AppColors.success
                    : AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completion',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(session.completionPercentage * 100).toInt()}%',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: session.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BreathingSession session) async {
    await _hapticManager.warning();
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Delete Session?',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
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
              'Delete',
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
      await ref.read(historyProvider.notifier).deleteSession(session.id);
    }
  }

  void _showClearAllDialog() async {
    await _hapticManager.warning();
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Clear All History?',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will delete all session records. This action cannot be undone.',
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
              'Clear All',
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
      await ref.read(historyProvider.notifier).deleteAllSessions();
    }
  }
}
