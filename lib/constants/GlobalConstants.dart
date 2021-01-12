import 'package:flutter/material.dart';

class StringConstants {
  static const bool debugMessages = true;
  static const kAppName = 'CarSpace';
  // static const kApiUrl = "https://api.zdgph.tech";
  static const kApiUrl = "https://21ff4677f07c.ngrok.io";
}

final ThemeData themeData = new ThemeData(
  // fontFamily: 'Roboto',
  brightness: Brightness.light,
  primarySwatch: MaterialColor(AppColors.indigo[900].value, AppColors.indigo),
  primaryColor: Colors.indigo[1000],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.indigo[900],
  accentColorBrightness: Brightness.light,
  secondaryHeaderColor: Color(0xFF534bae),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

class AppColors {
  AppColors._(); // this basically makes it so you can instantiate this class

  static const Map<int, Color> indigo = const <int, Color>{
    50: const Color(0xFFe8eaf6),
    100: const Color(0xFFc5cae9),
    200: const Color(0xFF9fa8da),
    300: const Color(0xFF7986cb),
    400: const Color(0xFF5c6bc0),
    500: const Color(0xFF3f51b5),
    600: const Color(0xFF3949ab),
    700: const Color(0xFF303f9f),
    800: const Color(0xFF283593),
    900: const Color(0xFF1a237e),
    1000: const Color(0xFF000051),
  };

  static const Map<int, Color> green = const <int, Color>{
    50: const Color(0xFFf2f8ef),
    100: const Color(0xFFdfedd8),
    200: const Color(0xFFc9e2be),
    300: const Color(0xFFb3d6a4),
    400: const Color(0xFFa3cd91),
    500: const Color(0xFF93c47d),
    600: const Color(0xFF8bbe75),
    700: const Color(0xFF80b66a),
    800: const Color(0xFF76af60),
    900: const Color(0xFF64a24d)
  };

  static const Map<int, Color> blue = const <int, Color>{
    50: const Color(0xFFDCF1FF),
    100: const Color(0xFFB5E1FF),
    200: const Color(0xFF66C2FF),
    300: const Color(0xFF88CFFF),
    400: const Color(0xFF67C2FF),
    500: const Color(0xFF48B6FF),
    600: const Color(0xFF2EACFF),
    700: const Color(0xFF1CA4FF),
    800: const Color(0xFF0D9EFF),
    900: const Color(0xFF0099FF)
  };
  static const Map<int, Color> grey = const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFE7E7E7),
    200: const Color(0xFFCCCCCC),
    300: const Color(0xFFBDBDBD),
    400: const Color(0xFFA7A7A7),
    500: const Color(0xFF797979),
    600: const Color(0xFF696969),
    700: const Color(0xFF4B4B4B),
    800: const Color(0xFF313131),
    900: const Color(0xFF000000)
  };
}
