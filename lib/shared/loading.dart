import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.BACKGROUND_COLOR,
      child: Center(
        child: SpinKitCircle(
          color: Constants.CANCEL_COLOR,
          size: 50.0,
        ),
      ),
    );
  }
}
