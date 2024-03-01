
import 'package:flutter/material.dart';

class LongButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color buttonBackground;
  final Color textColor;

  const LongButton({
    Key? key,
    required this.text,
    required this.press,
    required this.buttonBackground,
    required this.textColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        onPressed: press,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      color: buttonBackground,
      child: Text(
        text,
        style: TextStyle(color:textColor),
      ),
    );
  }
}
