import 'package:flutter/material.dart';

/// Dynamic splash screen widget with YTS logo and animated linear progress loader
class DynamicSplashScreen extends StatefulWidget {
  /// Callback function when splash screen completes
  final VoidCallback? onComplete;

  /// Duration for the splash screen display (minimum time)
  final Duration duration;

  const DynamicSplashScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<DynamicSplashScreen> createState() => _DynamicSplashScreenState();
}

class _DynamicSplashScreenState extends State<DynamicSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start logo animation immediately
    _logoController.forward();

    // Start progress animation after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();

    // Complete splash screen after animation duration
    await Future.delayed(widget.duration);
    if (mounted && widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic background color based on theme
    final backgroundColor = isDark
        ? const Color(0xFF0F172A) // Dark theme background
        : const Color(0xFFFAFAFA); // Light theme background

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF111827),
                    const Color(0xFF1F2937),
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFF5F5F5),
                    const Color(0xFFE5E7EB),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer to push content towards center
              const Spacer(flex: 2),

              // Animated YTS Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: _buildLogo(context),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // App title
              AnimatedBuilder(
                animation: _logoFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: Text(
                      'YTS Movies',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Animated Linear Progress Loader
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // Custom linear progress indicator
                        Container(
                          height: 4,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 4,
                              width: MediaQuery.of(context).size.width *
                                  _progressAnimation.value *
                                  0.7, // 0.7 accounts for padding
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.secondary,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Loading text
                        Text(
                          'Loading...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Spacer to center content
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    const logoSize = 120.0;

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Image.asset(
        'images/logo-YTS.png',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.onSurface
            : null,
        colorBlendMode: Theme.of(context).brightness == Brightness.dark
            ? BlendMode.srcIn
            : null,
      ),
    );
  }
}
