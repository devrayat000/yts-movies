part of app_theme;

extension DarkTheme on AppTheme {
  ThemeData get dark {
    final _dark = ThemeData.dark();
    final _text = _dark.textTheme;
    final _appbar = _dark.appBarTheme;
    final _input = _dark.inputDecorationTheme;
    final _fab = _dark.floatingActionButtonTheme;
    final _colorScheme = ColorScheme.dark();

    return _dark.copyWith(
      canvasColor: Colors.blueGrey[900],
      cardColor: Colors.blueGrey[700],
      appBarTheme: _appbar.copyWith(
        backgroundColor: Colors.blueGrey[900],
        iconTheme: IconThemeData(color: Colors.grey[100]),
      ),
      backgroundColor: Colors.blueGrey[900],
      scaffoldBackgroundColor: Colors.blueGrey[800],
      colorScheme: _colorScheme.copyWith(
        onSurface: Colors.white,
        surface: Colors.white70,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.black87,
        colorScheme: _colorScheme,
      ),
      textTheme: TextTheme(
        headline1: _text.headline1?.copyWith(
          color: Colors.white,
        ),
        headline2: _text.headline2?.copyWith(
          color: Colors.white,
        ),
        headline3: _text.headline3?.copyWith(
          color: Colors.white,
        ),
        headline4: _text.headline4?.copyWith(
          color: Colors.white,
        ),
        headline5: _text.headline5?.copyWith(
          color: Colors.white,
        ),
        headline6: _text.headline6?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.normal,
        ),
        subtitle1: _text.subtitle1?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
        subtitle2: _text.subtitle2?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: _input.copyWith(
        hintStyle: _input.hintStyle?.copyWith(
          color: Colors.blueGrey[50],
          fontStyle: FontStyle.italic,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(999.0),
          ),
          borderSide: BorderSide.none,
          // gapPadding: 10.0,
        ),
        fillColor: Colors.blueGrey[900],
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      ),
      floatingActionButtonTheme: _fab.copyWith(
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.grey[900],
      ),
    );
  }
}
