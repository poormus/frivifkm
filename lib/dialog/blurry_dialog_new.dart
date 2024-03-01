import 'dart:ui';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class BlurryDialogNew extends StatelessWidget {

  final String title;
  final VoidCallback continueCallBack;
  final TextStyle textStyle;

  BlurryDialogNew({
    required this.title,
    required this.continueCallBack,
    this.textStyle=const TextStyle (color: Colors.black,fontSize: 20,fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData.light(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
        backgroundColor: Constants.BACKGROUND_COLOR,
        child: Container(
            height: 140,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 10.0),
                      child: Text(title,style: textStyle,),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomTextButton(width: size.width*0.3, height: 35, text:Strings.CANCEL.tr(), textColor: Constants.BUTTON_COLOR, containerColor: Colors.white, press: (){Navigator.pop(context);}),
                        CustomTextButton(width: size.width*0.3, height: 35, text:Strings.APPROVE.tr(), textColor: Colors.white, containerColor: Constants.BUTTON_COLOR, press: continueCallBack),
                      ],
                    )
                  ],
                ),
                Align(
                  // These values are based on trial & error method
                  alignment: Alignment(1.1, -1.1),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.cancel,
                        color: Constants.CANCEL_COLOR,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}