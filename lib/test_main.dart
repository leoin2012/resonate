import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  if (kDebugMode) {
    print('[DEBUG] main: Starting application');
  }
  
  runApp(
    const ProviderScope(
      child: TestApp(),
    ),
  );
}

/// Minimal test app for debugging
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('[DEBUG] TestApp.build: Building test app');
    }
    
    return MaterialApp(
      title: 'Resonate Test',
      home: const TestScreen(),
    );
  }
}

/// Minimal test screen
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('[DEBUG] TestScreen.build: Building test screen');
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Test Screen'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'If you can see this, the app is working!',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Black screen issue might be in:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '- Router configuration',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '- Provider initialization',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '- Theme configuration',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
