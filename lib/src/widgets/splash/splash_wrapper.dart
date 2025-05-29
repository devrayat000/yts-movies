import 'package:flutter/material.dart';
import 'package:ytsmovies/src/widgets/splash/dynamic_splash_screen.dart';

/// Wrapper that manages the splash screen flow and transitions to the main app
class SplashWrapper extends StatefulWidget {
  /// The main app widget to show after splash
  final Widget child;

  /// Whether to show the splash screen (can be disabled for development)
  final bool showSplash;

  const SplashWrapper({
    super.key,
    required this.child,
    this.showSplash = true,
  });

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper>
    with TickerProviderStateMixin {
  bool _showingSplash = true;
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize transition animation
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    // Skip splash if disabled
    if (!widget.showSplash) {
      _showingSplash = false;
    }
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onSplashComplete() async {
    if (!mounted) return;

    // Start fade out transition
    await _transitionController.forward();

    // Switch to main app
    if (mounted) {
      setState(() {
        _showingSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showingSplash) {
      return widget.child;
    }

    return Stack(
      children: [
        // Main app (hidden behind splash)
        widget.child,

        // Dynamic splash screen with fade transition
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: DynamicSplashScreen(
                onComplete: _onSplashComplete,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ],
    );
  }
}
