part of './index.dart';

extension LightTheme on AppTheme {
  ThemeData get light {
    final _light = ThemeData.light();
    final _text = _light.textTheme;
    final _appbar = _light.appBarTheme;
    final _input = _light.inputDecorationTheme;
    final _fab = _light.floatingActionButtonTheme;
    final _chip = _light.chipTheme;
    final _colorScheme = ColorScheme.light();

    return _light.copyWith(
      canvasColor: Colors.grey[50],
      cardColor: Colors.teal[100],
      appBarTheme: _appbar.copyWith(
        backgroundColor: Colors.cyan[100],
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.grey.shade900,
        ),
      ),
      chipTheme: _chip.copyWith(
        backgroundColor: Colors.blueGrey[800],
        labelStyle: _chip.labelStyle.copyWith(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.grey[100],
      scaffoldBackgroundColor: Colors.grey[100],
      colorScheme: _colorScheme.copyWith(
        onSurface: Colors.black,
        surface: Colors.black87,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.black87,
        colorScheme: _colorScheme,
      ),
      textTheme: TextTheme(
        headline1: _text.headline1?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline2: _text.headline2?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline3: _text.headline3?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline4: _text.headline4?.copyWith(
          color: Colors.grey.shade900,
        ),
        headline5: _text.headline5?.copyWith(
          color: Colors.black,
        ),
        headline6: _text.headline6?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        subtitle1: _text.subtitle1?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        subtitle2: _text.subtitle2?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: _input.copyWith(
        hintStyle: _input.hintStyle?.copyWith(
          color: Colors.black87,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(999.0),
          ),
          borderSide: BorderSide.none,
          // gapPadding: 10.0,
        ),
        fillColor: Colors.grey[100],
        filled: true,
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      ),
      floatingActionButtonTheme: _fab.copyWith(
        backgroundColor: Colors.cyanAccent[700],
        foregroundColor: Colors.grey[50],
      ),
    );
  }
}
