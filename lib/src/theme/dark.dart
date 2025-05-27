part of app_theme;

extension DarkTheme on AppTheme {
  ThemeData get dark {
    final defaultDark = ThemeData.dark();
    final text = defaultDark.textTheme;
    final appbar = defaultDark.appBarTheme;
    final input = defaultDark.inputDecorationTheme;
    final fab = defaultDark.floatingActionButtonTheme;
    const colorScheme = ColorScheme.dark();

    return defaultDark.copyWith(
      canvasColor: Colors.blueGrey[900],
      cardColor: Colors.blueGrey[700],
      appBarTheme: appbar.copyWith(
        backgroundColor: Colors.blueGrey[900],
        iconTheme: IconThemeData(color: Colors.grey[100]),
      ),
      scaffoldBackgroundColor: Colors.blueGrey[800],
      colorScheme: colorScheme.copyWith(
        onSurface: Colors.white,
        surface: Colors.blueGrey[900],
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black87,
        colorScheme: colorScheme,
      ),
      textTheme: TextTheme(
        displayLarge: text.displayLarge?.copyWith(
          color: Colors.white,
        ),
        displayMedium: text.displayMedium?.copyWith(
          color: Colors.white,
        ),
        displaySmall: text.displaySmall?.copyWith(
          color: Colors.white,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: Colors.white,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          color: Colors.white,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.normal,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
        titleSmall: text.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: input.copyWith(
        hintStyle: input.hintStyle?.copyWith(
          color: Colors.blueGrey[50],
          fontStyle: FontStyle.italic,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(999.0),
          ),
          borderSide: BorderSide.none,
          // gapPadding: 10.0,
        ),
        fillColor: Colors.blueGrey[900],
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      ),
      floatingActionButtonTheme: fab.copyWith(
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.grey[900],
      ),
    );
  }
}
