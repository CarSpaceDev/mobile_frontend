import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final String activePrompt;
  final String inactivePrompt;
  final double width;

  const CustomSwitch(
      {Key key, this.value, this.onChanged, this.activeColor, this.activePrompt, this.inactivePrompt, this.width})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false ? widget.onChanged(true) : widget.onChanged(false);
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 35, minWidth: widget.width),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: _circleAnimation.value == Alignment.centerLeft ? Colors.grey : widget.activeColor),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 4.0, left: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _circleAnimation.value == Alignment.centerRight
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: Text(
                              widget.activePrompt != null ? widget.activePrompt : 'On',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16.0),
                            ),
                          )
                        : Container(),
                    Align(
                      alignment: _circleAnimation.value,
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                    _circleAnimation.value == Alignment.centerLeft
                        ? Padding(
                            padding: const EdgeInsets.only(left: 4.0, right: 5.0),
                            child: Text(
                              widget.inactivePrompt != null ? widget.inactivePrompt : 'Off',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 16.0),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
