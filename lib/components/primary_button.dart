import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final VoidCallback press;
  final color;

  const PrimaryButton({
    required this.text,
    required this.press,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Container(
      width: size.width*0.4,
      child: ElevatedButton(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor: MaterialStateProperty.all<Color>(color),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                )
            )
        ),
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(color: textColor!=null?Constants.BUTTON_COLOR:Colors.white),
        ),
      ),
    );
  }
}
