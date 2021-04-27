import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';

enum TextType {
  H1,
  H2,
  // H2Heavy,
  H3,
  H3Bold,
  H4,
  H5,
  H5Bold,
  // H6,
  Body,
  Caption,
  Button,
}

enum TextColor {
  Black,
  Primary,
  LightGrey,
  Grey,
  DarkGrey,
  White,
  Red,
  Green,
  Yellow,
  Blue,
}

class CSText extends StatelessWidget {
  final String text;
  final TextType textType;
  final TextColor textColor;
  final EdgeInsets padding;
  final TextAlign textAlign;
  final double lineSpacing;
  final int maxLines;
  final TextOverflow overflow;

  const CSText(this.text,
      {this.textType = TextType.Body,
      this.textColor = TextColor.Black,
      this.padding,
      this.textAlign,
      this.lineSpacing,
      this.maxLines,
      this.overflow = TextOverflow.visible})
      : super();
  @override
  Widget build(BuildContext context) {
    Color _color;

    switch (textColor) {
      case TextColor.Black:
        _color = csStyle.csBlack;
        break;
      case TextColor.Primary:
        _color = csStyle.primary;
        break;
      case TextColor.LightGrey:
        _color = csStyle.csGreyLight;
        break;
      case TextColor.Grey:
        _color = csStyle.csGrey;
        break;
      case TextColor.DarkGrey:
        _color = csStyle.csGreyDark;
        break;
      case TextColor.Red:
        _color = Colors.redAccent;
        break;
      case TextColor.Green:
        _color = Colors.green;
        break;
      case TextColor.Yellow:
        _color = csStyle.csYellow;
        break;
      case TextColor.Blue:
        _color = Colors.lightBlue;
        break;
      case TextColor.White:
        _color = Colors.white;
        break;
      default:
    }

    TextStyle style;
    var textTheme = Theme.of(context).textTheme;
    switch (textType) {
      case TextType.H1: //w900,42,
        style = textTheme.headline1;
        break;
      case TextType.H2: //w600,32
        style = textTheme.headline2;
        break;
      // case TextType.H2Heavy:
      //   style = textTheme.headline2.copyWith(fontWeight: FontWeight.w900);
      //   break;
      case TextType.H3: //w600, 24
        style = textTheme.headline3;
        break;
      case TextType.H3Bold: //w700, 24
        style = textTheme.headline3.copyWith(fontWeight: FontWeight.w700);
        break;
      case TextType.H4: //w600, 20
        style = textTheme.headline4;
        break;
      case TextType.H5: //w400,16
        style = textTheme.headline5;
        break;
      case TextType.H5Bold: //w700, 16
        style = textTheme.headline5.copyWith(
          fontWeight: FontWeight.w700,
        );
        break;
      // case TextType.H6: //w400, 14
      //   style = textTheme.headline6;
      //   break;
      case TextType.Body: //w400, 14
        style = textTheme.bodyText1;
        break;
      case TextType.Caption: //w400, 11
        style = textTheme.caption;
        break;
      case TextType.Button:
        style = textTheme.headline5.copyWith(
          fontWeight: FontWeight.bold,
        );
        break;
      default:
    }

    if (padding != null) {
      return Padding(
        padding: padding,
        child: Text(
          text,
          style: style.copyWith(
            color: _color,
            height: lineSpacing ?? 1.0,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
        ),
      );
    } else {
      return Text(
        text,
        style: style.copyWith(
          color: _color,
          height: lineSpacing ?? 1.0,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
  }
}
