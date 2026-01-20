import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';

/// Resonate App - Phase 2 + Phase 3
/// 
/// Features:
/// - Breathing animation with CustomPainter
/// - Taptic Engine haptic feedback
/// - Data persistence with SharedPreferences
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('========================================');
  debugPrint('🚀 Resonate Starting (Phase 2 + Phase 3)');
  debugPrint('========================================');
  
  runApp(
    const ProviderScope(
      child: ResonateApp(),
    ),
  );
}

/// Main application widget
class ResonateApp extends ConsumerWidget {
  const ResonateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    debugPrint('📱 Building ResonateApp...');
    
    return MaterialApp.router(
      title: 'Resonate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
