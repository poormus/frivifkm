import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/screens/auth/global_events.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../anim/slide_in_right.dart';
// import 'package:location/location.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;

class SignInApp extends StatefulWidget {
  final AuthService authService;

  const SignInApp({Key? key, required this.authService}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInApp> {
  String error = '';
  bool isLoading = false;
  String emailSignIn = '';
  String passwordSignIn = '';
  bool obscureSignInPassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKeySignIn = GlobalKey<FormState>();
  // Location location = new Location();

  Future signIn() async {
    //emailSignIn=emailController.text.trim();
    //passwordSignIn=passwordController.text.trim();

    if (Utils.validateSignIn(
        emailSignIn.trim().replaceAll(" ", ""), passwordSignIn, context)) {
      setState(() {
        isLoading = true;
      });
      await widget.authService
          .signInWithEmailAndPassword(
              emailSignIn.trim().replaceAll(" ", ""), passwordSignIn)
          .then((onSuccess) {
        setState(() {
          isLoading = false;
        });
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        error = err.toString();
        Utils.showSnackBar(context, error);
      });
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return buildBodyNew(size);
  }

  Widget buildBodyNew(Size size) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle
                ),
                child: Image.asset('assets/frivi_logo.png'),
              ),
              TextFieldInput(
                  textInputType: TextInputType.emailAddress,
                  autoCorrect: false,
                  hintText: 'E-mail'.tr(),
                  onChangeValue: (s) => emailSignIn = s,
                  isDone: false,
                  shouldObscureText: false),
              SizedBox(height: 6),
              TextFieldInput(
                  textInputType: TextInputType.visiblePassword,
                  hintText: 'Password'.tr(),
                  onChangeValue: (s) => passwordSignIn = s,
                  isDone: true,
                  shouldObscureText: true),
              SizedBox(height: 20),
              Container(
                height: 35,
                width: size.width,
                decoration: BoxDecoration(
                    color: Constants.BUTTON_COLOR,
                    borderRadius: BorderRadius.circular(5)),
                child: TextButton(
                  onPressed: isLoading ? () {} : signIn,
                  child: Text(
                    Strings.SIGN_IN.tr(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () => Navigation.navigateToForgotPasswordScreen(context),
                child: Text(Strings.FORGOT_PASSWORD.tr(),
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black)),
              ),
              SizedBox(height: 8),
              Container(
                  width: size.width * 0.5,
                  child: isLoading ? LinearProgressIndicator() : null),
            ],
          ),
        ),
      ],
    );
  }

  // void handleLocation() async{

  //   var status = await Permission.location.status;
  //   if(status.isGranted){
  //     setState(() {
  //       isLoading=true;
  //     });
  //     Utils.showToastWithoutContext('Getting location data please wait'.tr());
  //     LocationData _locationData=await location.getLocation();
  //     List<geocoding.Placemark> placeMarks =
  //         await geocoding.placemarkFromCoordinates(_locationData.latitude!,_locationData.longitude!);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     final area=placeMarks[0].subAdministrativeArea;
  //     final country=placeMarks[0].isoCountryCode;
  //     final guestId=prefs.getString('guestId')??'';
  //     print(placeMarks[0]);
  //     Navigator.push(context, SlideInRight(GlobalEvents(guestId: guestId,area: area,country: country)));
  //     setState(() {
  //       isLoading=false;
  //     });
  //   }else if(status.isDenied){
  //     Permission.location.request();
  //   }
  // }
}
