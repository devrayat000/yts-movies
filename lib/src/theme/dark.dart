part of 'index.dart';

extension DarkTheme on AppTheme {
  ThemeData get dark {
    final defaultDark = ThemeData.dark();
    final text = defaultDark.textTheme;
    final appbar = defaultDark.appBarTheme;
    final input = defaultDark.inputDecorationTheme;
    final fab = defaultDark.floatingActionButtonTheme;
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF818CF8), // Lighter indigo for dark mode
      primaryContainer: Color(0xFF3730A3),
      secondary: Color(0xFFA855F7), // Purple accent
      secondaryContainer: Color(0xFF6B21A8),
      surface: Color(0xFF111827),
      surfaceContainerHighest: Color(0xFF1F2937),
      onSurface: Color(0xFFF9FAFB),
      error: Color(0xFFF87171),
      onError: Color(0xFF111827),
    );

    return defaultDark.copyWith(
      canvasColor: const Color(0xFF0F172A),
      cardColor: const Color(0xFF1E293B).withAlpha((0.9 * 255).toInt()),
      appBarTheme: appbar.copyWith(
        backgroundColor:
            const Color(0xFF111827).withAlpha((0.95 * 255).toInt()),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFF3F4F6)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFF9FAFB),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: colorScheme,
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF818CF8),
        colorScheme: colorScheme,
      ),
      textTheme: TextTheme(
        displayLarge: text.displayLarge?.copyWith(
          color: const Color(0xFFF9FAFB),
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: text.displayMedium?.copyWith(
          color: const Color(0xFFF9FAFB),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        displaySmall: text.displaySmall?.copyWith(
          color: const Color(0xFFF3F4F6),
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: const Color(0xFFF3F4F6),
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          color: const Color(0xFFF3F4F6),
          fontWeight: FontWeight.w600,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: const Color(0xFFF9FAFB),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: const Color(0xFFE5E7EB),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: text.titleSmall?.copyWith(
          color: const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: text.bodyLarge?.copyWith(
          color: const Color(0xFFE5E7EB),
          letterSpacing: 0.5,
        ),
        bodyMedium: text.bodyMedium?.copyWith(
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.25,
        ),
      ),
      inputDecorationTheme: input.copyWith(
        hintStyle: input.hintStyle?.copyWith(
          color: const Color(0xFF6B7280),
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
        fillColor: const Color(0xFF1F2937),
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      ),
      floatingActionButtonTheme: fab.copyWith(
        backgroundColor: const Color(0xFF818CF8),
        foregroundColor: const Color(0xFF111827),
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
