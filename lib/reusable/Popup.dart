import 'package:carspace/constants/GlobalConstants.dart';
import 'package:flutter/material.dart';

import 'CSText.dart';
import 'CSTile.dart';

class PopUp extends StatelessWidget {
  static Future showError({
    @required BuildContext context,
    @required String title,
    @required String body,
  }) =>
      show(
        context: context,
        title: title,
        body: body,
        child: null,
        backgroundColor: csStyle.csWhite,
        titleColor: TextColor.Primary,
        bodyColor: TextColor.Primary,
        warning: true,
      );

  static Future showInfo(
          {@required BuildContext context,
          @required String title,
          String body,
          Widget child,
          Function onAcknowledge}) =>
      show(
          context: context,
          title: title,
          body: body,
          child: child,
          backgroundColor: csStyle.csWhite,
          titleColor: TextColor.Primary,
          bodyColor: TextColor.Primary,
          onAcknowledge: onAcknowledge);

  static Future showOption({
    @required BuildContext context,
    @required String title,
    @required String body,
    @required Function onAccept,
  }) =>
      show(
        context: context,
        title: title,
        body: body,
        child: null,
        backgroundColor: csStyle.csWhite,
        titleColor: TextColor.Primary,
        bodyColor: TextColor.Primary,
        onAccept: onAccept,
      );

  static Future show({
    @required BuildContext context,
    @required Color backgroundColor,
    @required String title,
    @required String body,
    @required Widget child,
    @required TextColor titleColor,
    @required TextColor bodyColor,
    Function onAccept,
    Function onAcknowledge,
    bool warning = false,
  }) {
    var height = MediaQuery.of(context).size.height;

    return showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return;
      },
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierLabel: '',
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;

        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * height, 0.0),
          child: PopUp(
            title: title,
            body: body,
            child: child,
            backgroundColor: backgroundColor,
            titleColor: titleColor,
            bodyColor: bodyColor,
            onAcknowledge: onAcknowledge,
            onAccept: onAccept,
            warning: warning,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 700),
    );
  }

  const PopUp({
    Key key,
    @required this.title,
    @required this.body,
    @required this.child,
    @required this.backgroundColor,
    @required this.titleColor,
    @required this.bodyColor,
    this.onAccept,
    this.onAcknowledge,
    this.warning = false,
  }) : super(key: key);

  final Color backgroundColor;
  final String title;
  final String body;
  final Widget child;
  final TextColor titleColor;
  final TextColor bodyColor;
  final Function onAccept;
  final Function onAcknowledge;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 40),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: CSTile(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CSSegmentedTile(
              title: title != null
                  ? Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (warning)
                            Padding(
                              padding: const EdgeInsets.only(right: 8, left: 16),
                              child: Icon(
                                Icons.info,
                                size: 24,
                                color: csStyle.primary,
                              ),
                            ),
                          Expanded(
                            child: CSText(
                              title,
                              textType: TextType.H3Bold,
                              textColor: titleColor,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (warning)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 16),
                              child: Icon(
                                Icons.info,
                                size: 24,
                                color: csStyle.primary,
                              ),
                            ),
                        ],
                      ),
                    )
                  : null,
              body: child ??
                  CSText(
                    body,
                    textType: TextType.H4,
                    textColor: bodyColor,
                    textAlign: TextAlign.center,
                  ),
              dottedDivider: true,
            ),
            if (onAccept != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      child: CSText(
                        "YES",
                        textType: TextType.Button,
                        textColor: TextColor.Primary,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Container(width: 8),
                    ElevatedButton(
                      child: CSText(
                        "NO",
                        textType: TextType.Button,
                        textColor: TextColor.White,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onAccept();
                      },
                    ),
                  ],
                ),
              ),
            if (onAccept == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      child: CSText(
                        "OK",
                        textType: TextType.Button,
                        textColor: TextColor.Primary,
                      ),
                      onPressed: () {
                        if (onAcknowledge != null) onAcknowledge();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
