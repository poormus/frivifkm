import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';


// ignore:must_be_immutable
class BaseScaffoldMainScreenItem extends StatelessWidget {
  final Widget body;
  Widget? fab;
  BaseScaffoldMainScreenItem({Key? key, required this.body,this.fab}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(

      backgroundColor: Constants.BACKGROUND_COLOR,
      body: Container(
        height: size.height - 80,
        width: size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: body,
      ),
      floatingActionButton: fab,
    );

  }
}
