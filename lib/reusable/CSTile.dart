import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'DashedLine.dart';

enum TileColor { None, White, Grey, DarkGrey, Primary, Secondary }

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
  final MainAxisAlignment expandedMainAxisAlignment; // the main axis alignment of the content column if the tile is expanded
  final void Function() onTap;
  final bool arrowRight;
  final bool textFieldRight;
  final bool settingsRight;
  final bool showBorder;
  final bool dottedDivider;
  final bool solidDivider;
  final bool shadow;
  final double borderRadius;

  const CSSegmentedTile(
      {Key key,
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
      this.linePaddingLeft = 16,
      this.linePaddingRight = 16,
      this.expanded = false,
      this.expandBody = false,
      this.expandedMainAxisAlignment = MainAxisAlignment.center,
      this.arrowRight = false,
      this.textFieldRight = false,
      this.settingsRight = false,
      this.dottedDivider = false,
      this.showBorder = false,
      this.solidDivider = false,
      this.shadow = false,
      this.borderRadius = 0})
      : super(key: key);
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
      dottedDivider: dottedDivider,
      solidDivider: solidDivider,
      showBorder: showBorder,
      shadow: shadow,
      borderRadius: borderRadius,
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
          if (arrowRight) Padding(padding: EdgeInsets.only(left: contentPadding), child: Icon(CupertinoIcons.chevron_right)),
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
  final bool showBorder;
  final bool dottedDivider;
  final bool solidDivider;
  final bool shadow;
  final double borderRadius;

  const CSTile(
      {Key key,
      this.child,
      this.selected = false,
      this.margin = const EdgeInsets.symmetric(vertical: 16),
      this.padding = const EdgeInsets.all(16),
      this.color = TileColor.White,
      this.onTap,
      this.linePaddingLeft = 16,
      this.linePaddingRight = 16,
      this.expanded = false,
      this.dottedDivider = false,
      this.solidDivider = false,
      this.showBorder = false,
      this.shadow = false,
      this.borderRadius = 0})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: margin,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: showBorder
                ? Border.all(
                    color: colors(TileColor.Primary),
                  )
                : null,
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 0,
                      blurRadius: 6,
                    ),
                  ]
                : null,
            color: colors(color),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (expanded) Expanded(child: _child()),
              if (!expanded) _child(),
              if (dottedDivider)
                Padding(
                  padding: EdgeInsets.only(left: linePaddingLeft, right: linePaddingRight),
                  child: DashedLine(
                    color: colors(TileColor.Primary),
                    dashWidth: 2.5,
                    height: 1.5,
                  ),
                ),
              if (solidDivider)
                Padding(
                  padding: EdgeInsets.only(left: linePaddingLeft, right: linePaddingRight),
                  child: Divider(height: 1, thickness: 1, color: colors(TileColor.Primary)),
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
      case TileColor.DarkGrey:
        return csStyle.csGrey;
        break;
      case TileColor.Primary:
        return csStyle.primary;
        break;
      case TileColor.Secondary:
        return Colors.blue[500];
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
          width: 2,
          // left: BorderSide(
          // ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        _padding.left,
        _padding.top,
        _padding.right,
        _padding.bottom,
      ),
      child: Center(child: child),
    );
  }
}
