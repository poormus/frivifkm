
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final double width;
  final double height;
  final String text;
  final Color textColor;
  final Color containerColor;
  final VoidCallback press;

  const CustomTextButton({
    required this.width,
    required this.height,
    required this.text,
    required this.textColor,
    required this.containerColor,
    required this.press,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(8)
      ),
      child: TextButton(
        onPressed: press,
        child: Text(text,style: appTextStyle.copyWith(color: textColor)),
      ),
    );
  }


}

