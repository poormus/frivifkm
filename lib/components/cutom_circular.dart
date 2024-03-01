import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProgressWithIcon extends StatelessWidget {
  const ProgressWithIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
              width: 100,
              height: 100,
              child: SpinKitCircle(
                color: Constants.CANCEL_COLOR,
                size: 100.0,
              )),
          Image.asset(
            // you can replace this with Image.asset
            'assets/frivi_logo.png',
            fit: BoxFit.cover,
            height: 40,
            width: 40,
          )
        ],
      ),
    );
  }
}
