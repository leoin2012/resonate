import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/router/app_router.dart';

/// Resonate App - Phase 1: Basic UI Framework
/// 
/// This simplified version removes logger/error_monitor dependencies
/// to verify basic routing and theming work on iOS device.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('========================================');
  debugPrint('🚀 Resonate Phase 1 Starting');
  debugPrint('========================================');
  
  runApp(
    const ProviderScope(
      child: ResonateApp(),
    ),
  );
}

/// Main app widget
class ResonateApp extends ConsumerWidget {
  const ResonateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📱 Building ResonateApp...');
    
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Resonate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
