import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';


// ignore:must_be_immutable
class BaseScaffold extends StatelessWidget {
  final String appBarName;
  final Widget body;
  final bool shouldScroll;
  Widget? floatingActionButton;
  List<Widget>? actions;
  Widget? bottomNav;

  BaseScaffold({Key? key, required this.appBarName,
    required this.body,this.floatingActionButton,this.actions,
    required this.shouldScroll,this.bottomNav}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return shouldScroll?GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Constants.BACKGROUND_COLOR,
        bottomNavigationBar: bottomNav,
        appBar: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppBar(
                actions: actions,
                iconTheme: IconThemeData(
                    color: Colors.black),
                backgroundColor: Constants.BACKGROUND_COLOR,
                centerTitle: true,
                title: Text(
                  appBarName,
                  style: TextStyle(color: Colors.black),
                ),
                elevation: 0,
              ),
            ),
            preferredSize: Size.fromHeight(80)),
        body: Container(
          height: size.height - 80,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: body,
        ),
        floatingActionButton: floatingActionButton,
      ),
    ):
    GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.BACKGROUND_COLOR,
        appBar: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppBar(
                actions: actions,
                iconTheme: IconThemeData(
                    color: Colors.black),
                backgroundColor: Constants.BACKGROUND_COLOR,
                centerTitle: true,
                title: Text(
                  appBarName,
                  style: TextStyle(color: Colors.black),
                ),
                elevation: 0,
              ),
            ),
            preferredSize: Size.fromHeight(80)),
        body: Container(
          height: size.height - 80,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: body,
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
