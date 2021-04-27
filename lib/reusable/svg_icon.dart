import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum SvgFile {
  Mastercard,
  Amex,
  Discover,
  Visa,
}

Map<SvgFile, String> map = {
  SvgFile.Mastercard: 'assets/card_icons/mastercard.svg',
  SvgFile.Amex: 'assets/card_icons/amex.svg',
  SvgFile.Discover: 'assets/card_icons/discover.svg',
  SvgFile.Visa: 'assets/card_icons/visa.svg',
};

enum SvgColor {
  None,
  Black,
  White,
  Primary,
  Grey,
  Red,
}

class SvgIcon extends StatelessWidget {
  final SvgFile svgFile;
  final double size;
  final EdgeInsets padding;
  final SvgColor svgColor;

  const SvgIcon(
    this.svgFile, {
    Key key,
    this.size = 30.0,
    this.svgColor = SvgColor.None,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _color;

    switch (svgColor) {
      case SvgColor.Black:
        _color = csStyle.csBlack;
        break;
      case SvgColor.White:
        _color = csStyle.csWhite;
        break;
      case SvgColor.Primary:
        _color = csStyle.primary;
        break;
      case SvgColor.Grey:
        _color = csStyle.csGrey;
        break;
      case SvgColor.Red:
        _color = csStyle.csRed;
        break;
      default:
    }

    return Container(
      padding: padding,
      width: size,
      height: size,
      child: SvgPicture.asset(
        map[svgFile],
        color: _color,
      ),
    );
  }
}
