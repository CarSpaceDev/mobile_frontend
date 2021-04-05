import 'dart:math';

import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum TileColor { None, White, Grey, Primary }

class CSSegmentedTile extends StatelessWidget {
  final bool selected; // if the tile is selected and should have green line shown
  final EdgeInsets margin;
  final EdgeInsets padding; // padding
  final TileColor color; // background color of tile
  final Widget leading; // Leading widget
  final Widget trailing; // Trailing widget
  final Widget title; // Title widget
  final Widget body; // widget shown under the title row
  final double contentPadding; // padding between the center piece and leading/trailing widgets
  final double linePaddingLeft; // left padding of the bottom divider
  final double linePaddingRight; // right padding of the bottom divider
  final bool expanded; // if the tile should expand in the vertical direction
  final bool expandBody; // if the body should be expanded when tile is expanded
  final MainAxisAlignment
      expandedMainAxisAlignment; // the main axis alignment of the content column if the tile is expanded
  final void Function() onTap;
  final bool arrowRight;
  final bool textFieldRight;
  final bool settingsRight;
  final bool showDivider;
  final bool primaryDivider;

  const CSSegmentedTile({
    Key key,
    this.title,
    this.body,
    this.leading,
    this.trailing,
    this.color,
    this.onTap,
    this.selected = false,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.contentPadding = 16,
    this.linePaddingLeft = 0,
    this.linePaddingRight = 0,
    this.expanded = false,
    this.expandBody = false,
    this.expandedMainAxisAlignment = MainAxisAlignment.center,
    this.arrowRight = false,
    this.textFieldRight = false,
    this.settingsRight = false,
    this.showDivider = true,
    this.primaryDivider = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CSTile(
      margin: margin,
      selected: selected,
      padding: padding,
      color: color,
      onTap: onTap,
      linePaddingLeft: linePaddingLeft,
      linePaddingRight: linePaddingRight,
      expanded: expanded,
      showDivider: showDivider,
      primaryDivider: primaryDivider,
      child: Row(
        children: [
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(right: contentPadding),
              child: leading,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: expandedMainAxisAlignment,
              children: [
                if (title != null) title,
                if (body != null && expandBody)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: body,
                    ),
                  ),
                if (body != null && !expandBody)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: body,
                  ),
              ],
            ),
          ),
          if (trailing != null)
            Padding(
              padding: EdgeInsets.only(left: contentPadding),
              child: trailing,
            ),
          if (settingsRight)
            Padding(
              padding: EdgeInsets.only(left: contentPadding),
              child: Icon(Icons.more_vert),
            ),
          if (arrowRight)
            Padding(
              padding: EdgeInsets.only(left: contentPadding),
              child: SvgPicture.asset(
                'assets/icons/icon_chevron_thin_right.svg',
                color: csStyle.csBlack,
                width: getRelativeSize(context, 12),
              ),
            ),
          if (textFieldRight)
            Padding(
              padding: EdgeInsets.only(left: contentPadding),
              child: Icon(Icons.comment),
            ),
        ],
      ),
    );
  }
}

class CSTile extends StatelessWidget {
  final bool selected;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final TileColor color;
  final Widget child;
  final void Function() onTap;
  final double linePaddingLeft;
  final double linePaddingRight;
  final bool expanded;
  final bool showDivider;
  final bool primaryDivider;

  const CSTile({
    Key key,
    this.child,
    this.selected = false,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.padding,
    this.color = TileColor.White,
    this.onTap,
    this.linePaddingLeft = 0,
    this.linePaddingRight = 0,
    this.expanded = false,
    this.showDivider = false,
    this.primaryDivider = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: margin,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: colors(color),
          child: Column(
            children: [
              if (expanded) Expanded(child: _child()),
              if (!expanded) _child(),
              if (showDivider)
                Padding(
                  padding: EdgeInsets.only(left: linePaddingLeft, right: linePaddingRight),
                  child: primaryDivider
                      ? Divider(
                          height: 2,
                          thickness: 2,
                          color: csStyle.primary,
                        )
                      : Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: csStyle.csGreyDivider,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color colors(TileColor color) {
    switch (color) {
      case TileColor.Grey:
        return csStyle.csGreyBackground;
        break;
      case TileColor.Primary:
        return csStyle.primary;
        break;
      case TileColor.White:
        return csStyle.csWhite;
        break;
      default:
        return Colors.transparent;
        break;
    }
  }

  Widget _child() {
    var _padding = padding ?? const EdgeInsets.all(16);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? csStyle.primary : Colors.transparent,
          width: min(2, _padding.left),
          // left: BorderSide(
          // ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        max(_padding.left - 2.0, 0.0),
        _padding.top,
        _padding.right,
        _padding.bottom,
      ),
      child: Center(child: child),
    );
  }
}
