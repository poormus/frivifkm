import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class ElevatedCustomButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final VoidCallback press;
  final color;

  const ElevatedCustomButton({
    required this.text,
    required this.press,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ))),
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(
            color: textColor != null ? Constants.BUTTON_COLOR : Colors.white),
      ),
    );
  }
}
