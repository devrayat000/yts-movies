part of 'index.dart';

extension LightTheme on AppTheme {
  ThemeData get light {
    final defaultLight = ThemeData.light();
    final text = defaultLight.textTheme;
    final appbar = defaultLight.appBarTheme;
    final input = defaultLight.inputDecorationTheme;
    final fab = defaultLight.floatingActionButtonTheme;
    final chip = defaultLight.chipTheme;
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF6366F1), // Modern indigo
      primaryContainer: Color(0xFFE0E7FF),
      secondary: Color(0xFF8B5CF6), // Purple accent
      secondaryContainer: Color(0xFFF3E8FF),
      surface: Color(0xFFFAFAFA),
      surfaceContainerHighest: Color(0xFFF5F5F5),
      onSurface: Color(0xFF1F2937),
      error: Color(0xFFEF4444),
      onError: Colors.white,
    );

    return defaultLight.copyWith(
      canvasColor: const Color(0xFFFAFAFA),
      cardColor: Colors.white.withAlpha((0.9 * 255).toInt()),
      appBarTheme: appbar.copyWith(
        backgroundColor: Colors.white.withAlpha((0.95 * 255).toInt()),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF374151)),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      chipTheme: chip.copyWith(
        backgroundColor: colorScheme.primaryContainer,
        labelStyle: chip.labelStyle?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: colorScheme,
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF6366F1),
        colorScheme: colorScheme,
      ),
      textTheme: TextTheme(
        displayLarge: text.displayLarge?.copyWith(
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: text.displayMedium?.copyWith(
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        displaySmall: text.displaySmall?.copyWith(
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: const Color(0xFF374151),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          color: const Color(0xFF374151),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: const Color(0xFF374151),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: text.titleSmall?.copyWith(
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: text.bodyLarge?.copyWith(
          color: const Color(0xFF374151),
          letterSpacing: 0.5,
        ),
        bodyMedium: text.bodyMedium?.copyWith(
          color: const Color(0xFF6B7280),
          letterSpacing: 0.25,
        ),
      ),
      inputDecorationTheme: input.copyWith(
        hintStyle: input.hintStyle?.copyWith(
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(16.0),
          ),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      ),
      floatingActionButtonTheme: fab.copyWith(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 8,
        focusElevation: 12,
        hoverElevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
