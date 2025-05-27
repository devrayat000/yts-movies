part of app_theme;

extension LightTheme on AppTheme {
  ThemeData get light {
    final defaultLight = ThemeData.light();
    final text = defaultLight.textTheme;
    final appbar = defaultLight.appBarTheme;
    final input = defaultLight.inputDecorationTheme;
    final fab = defaultLight.floatingActionButtonTheme;
    final chip = defaultLight.chipTheme;
    const colorScheme = ColorScheme.light();

    return defaultLight.copyWith(
      canvasColor: Colors.grey[50],
      cardColor: Colors.teal[100],
      appBarTheme: appbar.copyWith(
        backgroundColor: Colors.cyan[100],
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.grey.shade900,
        ),
      ),
      chipTheme: chip.copyWith(
        backgroundColor: Colors.blueGrey[800],
        labelStyle: chip.labelStyle?.copyWith(
          color: Colors.white,
        ),
      ),
      scaffoldBackgroundColor: Colors.grey[100],
      colorScheme: colorScheme.copyWith(
        onSurface: Colors.black,
        surface: Colors.grey[100],
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.black87,
        colorScheme: colorScheme,
      ),
      textTheme: TextTheme(
        displayLarge: text.displayLarge?.copyWith(
          color: Colors.grey.shade900,
        ),
        displayMedium: text.displayMedium?.copyWith(
          color: Colors.grey.shade900,
        ),
        displaySmall: text.displaySmall?.copyWith(
          color: Colors.grey.shade900,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          color: Colors.grey.shade900,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          color: Colors.black,
        ),
        titleLarge: text.titleLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        titleMedium: text.titleMedium?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        titleSmall: text.titleSmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: input.copyWith(
        hintStyle: input.hintStyle?.copyWith(
          color: Colors.black87,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(999.0),
          ),
          borderSide: BorderSide.none,
          // gapPadding: 10.0,
        ),
        fillColor: Colors.grey[100],
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      ),
      floatingActionButtonTheme: fab.copyWith(
        backgroundColor: Colors.cyanAccent[700],
        foregroundColor: Colors.grey[50],
      ),
    );
  }
}
