import 'dart:ui';

import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class BlurryDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback continueCallBack;
  final TextStyle textStyle;
  final VoidCallback? cancelCallBack;

  BlurryDialog({
    required this.title,
    required this.content,
    required this.continueCallBack,
    this.cancelCallBack,
    this.textStyle = const TextStyle(color: Colors.black),
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
          backgroundColor: Constants.BACKGROUND_COLOR,
          title: new Text(
            title,
            style: textStyle,
          ),
          content: new Text(
            content,
            style: textStyle,
          ),
          actions: <Widget>[
            cancelCallBack != null
                ? new ElevatedCustomButton(
                    text: 'Cancel',
                    press: cancelCallBack!,
                    color: Constants.CANCEL_COLOR)
                : Container(),
            new ElevatedCustomButton(
                text: 'Continue',
                press: continueCallBack,
                color: Constants.CANCEL_COLOR),
          ],
        ));
  }
}
