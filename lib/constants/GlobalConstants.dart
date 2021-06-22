import 'package:flutter/material.dart';

class StringConstants {
  static const bool debugMessages = true;
  static const kAppName = 'CarSpace';
  static const kApiUrl = "https://api.zdgph.tech";
  static const kMqttUrl = 'mqtt.zdgph.tech';
  static const kMqttUser = 'zdgdev';
  static const kMqttPass = 'zdgcs21!';
}

final csStyle = CSTheme();

class CSTheme {
  Color primary = Colors.indigo[900];
  Color csBlack = Color(0xFF000000);
  Color csWhite = Color(0xFFFFFFFF);
  Color csGreyLight = Color(0xFFC3C3C3);
  Color csGrey = Color(0xFF888888);
  Color csGreyDark = Color(0xFF646464);
  Color csGreyDivider = Color(0xFFDDDDDD);
  Color csGreyBackground = Color(0xFFF8F8F8);
  Color csRed = Color(0xFFDA2C43);
  Color csYellow = Color(0xFFD5B11D);

  TextStyle appBarTextDark;
  TextStyle appBarTextLight;
  TextStyle title;
  TextStyle headline1;
  TextStyle headline2;
  TextStyle headline3;
  TextStyle headline4;
  TextStyle headline5;
  TextStyle headline6;
  TextStyle body;
  TextStyle caption;
  AppBarTheme appBarThemePrimary;
  AppBarTheme appBarThemeWhite;
  OutlinedButtonThemeData outlinedButtonThemeActive;
  OutlinedButtonThemeData outlinedButtonThemeInactive;
  CSTheme() {
    headline1 = TextStyle(fontWeight: FontWeight.w900, fontSize: 42);
    headline2 = TextStyle(fontWeight: FontWeight.w700, fontSize: 32);
    headline3 = TextStyle(fontWeight: FontWeight.w600, fontSize: 24);
    headline4 = TextStyle(
        fontWeight: FontWeight.w600, fontSize: 20, letterSpacing: 0.54);
    headline5 = TextStyle(
        fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0.32);
    headline6 = TextStyle(
        fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.42);
    body = TextStyle(
        fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.42);
    caption = TextStyle(
        fontWeight: FontWeight.w400, fontSize: 11, letterSpacing: 0.33);

    appBarTextDark = TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 24,
        letterSpacing: 1,
        color: this.csWhite,
        fontFamily: "Roboto");

    appBarTextLight = TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: 0.54,
        color: this.csBlack,
        fontFamily: "Roboto");

    appBarThemePrimary = AppBarTheme(
        color: this.primary,
        textTheme: TextTheme(headline6: appBarTextDark),
        brightness: Brightness.dark,
        elevation: 3,
        actionsIconTheme: IconThemeData(color: csWhite, size: 20),
        iconTheme: IconThemeData(color: csWhite, size: 20));
    appBarThemeWhite = AppBarTheme(
        color: this.csWhite,
        centerTitle: true,
        textTheme: TextTheme(headline6: appBarTextLight),
        brightness: Brightness.light,
        elevation: 3,
        shadowColor: csGreyDivider,
        actionsIconTheme: IconThemeData(color: csGreyLight, size: 30),
        iconTheme: IconThemeData(color: csGreyLight, size: 30));
    outlinedButtonThemeActive = OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            primary: primary,
            textStyle:
                headline6.copyWith(letterSpacing: 1.12, color: csBlack)));
    outlinedButtonThemeInactive = OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: csGreyBackground),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            primary: primary,
            textStyle:
                headline6.copyWith(letterSpacing: 1.12, color: csBlack)));
  }

  ThemeData theme() {
    return ThemeData(
      primaryColor: this.primary,
      primarySwatch: createMaterialColor(this.primary),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: "Roboto",
      textTheme: createTextTheme(),
      scaffoldBackgroundColor: csGreyBackground,
      primaryColorDark: csBlack,
      primaryColorLight: csWhite,
      outlinedButtonTheme: outlinedButtonThemeActive,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ))),
      ),
    );
  }

  TextTheme createTextTheme() {
    return TextTheme(
      headline1: headline1,
      headline2: headline2,
      headline3: headline3,
      headline4: headline4,
      headline5: headline5,
      headline6: headline6,
      bodyText1: body,
      bodyText2: body,
      caption: caption,
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}
