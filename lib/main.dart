import 'dart:async';

import 'package:flutter/material.dart';

import 'privacy_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';

void main() {
  runApp(const BlurGlassApp());
}

class BlurGlassApp extends StatelessWidget {
  const BlurGlassApp({super.key, this.controller});

  /// Injectable for tests; a real controller is created when omitted.
  final PrivacyController? controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blur Glass',
      debugShowCheckedModeBanner: false,
      theme: BlurGlassTheme.dark(),
      home: _Root(controller: controller),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root({this.controller});

  final PrivacyController? controller;

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late final PrivacyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PrivacyController();
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
    return StreamBuilder<AppPhase>(
      stream: _controller.phase,
      initialData: _controller.currentPhase,
      builder: (context, snapshot) {
        final phase = snapshot.data ?? AppPhase.loading;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (phase) {
            AppPhase.dashboard => DashboardScreen(
                key: const ValueKey('dashboard'), controller: _controller),
            AppPhase.onboarding => OnboardingScreen(
                key: const ValueKey('onboarding'), controller: _controller),
            AppPhase.loading => const _Splash(key: ValueKey('splash')),
          },
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 64),
            const SizedBox(height: 20),
            Text(
              'Connecting to the Blur Glass agent…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
