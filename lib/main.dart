import 'dart:async';

import 'package:flutter/material.dart';

import 'privacy_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const BlurGlassApp());
}

class BlurGlassApp extends StatelessWidget {
  const BlurGlassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blur Glass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3DDAD7),
          brightness: Brightness.dark,
        ),
      ),
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late final PrivacyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PrivacyController();
    unawaited(_controller.init());
    _controller.errors.listen((message) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1220), Color(0xFF101826), Color(0xFF14243A)],
        ),
      ),
      child: StreamBuilder<AppPhase>(
        stream: _controller.phase,
        initialData: _controller.currentPhase,
        builder: (context, snapshot) {
          final phase = snapshot.data ?? AppPhase.loading;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: switch (phase) {
              AppPhase.dashboard => DashboardScreen(
                  key: const ValueKey('dashboard'), controller: _controller),
              AppPhase.onboarding => OnboardingScreen(
                  key: const ValueKey('onboarding'), controller: _controller),
              AppPhase.loading => const _Splash(key: ValueKey('splash')),
            },
          );
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.blur_on_rounded, size: 48, color: Colors.white70),
            SizedBox(height: 12),
            Text('Connecting to the Blur Glass agent…'),
          ],
        ),
      ),
    );
  }
}
