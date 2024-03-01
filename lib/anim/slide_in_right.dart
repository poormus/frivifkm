import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlideInRight extends PageRouteBuilder{
  final Widget widget;

  SlideInRight(this.widget):super(
    opaque: false,
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (context,animation,secondAnimation)=>widget,

  );
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child)=>
      SlideTransition(position: Tween<Offset>(
        begin: Offset(-1,0),
        end: Offset.zero
      ).animate(animation),
          child: widget);
}