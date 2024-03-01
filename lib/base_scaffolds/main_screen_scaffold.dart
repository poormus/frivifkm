import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class MainScreenBaseScaffold extends StatelessWidget {
  final Widget appBar;
  final Widget body;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget drawer;
  final Widget bottomNavBar;
  final Size size;
  final Widget endDrawer;
  const MainScreenBaseScaffold({
    Key? key,
    required this.appBar,
    required this.body,
    required this.scaffoldKey,
    required this.drawer,
    required this.bottomNavBar,
    required this.size,
    required this.endDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        endDrawer: endDrawer,
        drawer: drawer,
        key: scaffoldKey,
        backgroundColor: Constants.BACKGROUND_COLOR,
        appBar: PreferredSize(
            child: Padding(padding: const EdgeInsets.only(top: 50.0), child: appBar),
            preferredSize: Size.fromHeight(80)),
        body: Container(
          height: size.height - 80,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: body,
        ),
        bottomNavigationBar: bottomNavBar,
      ),
    );
  }
}
