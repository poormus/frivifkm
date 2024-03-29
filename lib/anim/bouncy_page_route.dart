import 'package:flutter/cupertino.dart';

class BouncyPageRoute extends PageRouteBuilder {
  final Widget widget;

  BouncyPageRoute(this.widget)
      : super(
            transitionDuration: Duration(milliseconds: 500),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              animation = CurvedAnimation(parent: animation, curve: Curves.elasticIn);
              return ScaleTransition(
                  scale: animation, child: child, alignment: Alignment.center);
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return widget;
            });
}
