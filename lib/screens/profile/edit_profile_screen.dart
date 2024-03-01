import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/dialog/select_image_dialog.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/services/profile_service.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants.dart';

class EditProfile extends StatefulWidget {
  final CurrentUserData userData;

  const EditProfile({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late String? userPhone;
  late String userName;
  late String userSurname;
  File? imageFile;
  final picker = ImagePicker();
  final authService = AuthService();
  final profileService = ProfileService();
  final key = GlobalKey<FormState>();

  showSelectImageSourceDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SelectImageSourceDialog(
              selectedImage: (onImageSelected onSelected) async {
            setState(() {
              imageFile = onSelected.imageFile;
            });
          });
        }).then((value) => null);
  }

  Future updateUserInfo() async {
    if (key.currentState!.validate()) {
      await profileService
          .updateUserInfo(widget.userData.uid, userName, userSurname, userPhone,
              imageFile, widget.userData.userUrl, context)
          .catchError(
              (onError) => Utils.showToastWithoutContext(onError.toString()));
    }
  }

  @override
  void initState() {
    userName = widget.userData.userName;
    userSurname = widget.userData.userSurname;
    userPhone = widget.userData.userPhone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final uid = widget.userData.uid;
    return BaseScaffold(
        appBarName: 'Edit profile'.tr(),
        body: buildBody(uid, size),
        shouldScroll: true);
    return buildScaffold(
        'Edit profile'.tr(), context, buildBody(uid, size), saveButton());
  }

  Widget saveButton() {
    return ElevatedCustomButton(
        text: 'Update'.tr(),
        press: updateUserInfo,
        color: Constants.BUTTON_COLOR);
  }

  Widget buildBody(String uid, Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 5),
          Align(
              alignment: Alignment.topCenter,
              child: Stack(
                children: [
                  Container(
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageFile == null
                                ? NetworkImage(widget.userData.userUrl)
                                : FileImage(imageFile!) as ImageProvider)),
                  ),
                  Positioned(
                      right: 5,
                      bottom: 5,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Constants.BACKGROUND_COLOR,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white)),
                        child: Center(
                            child: IconButton(
                                onPressed: showSelectImageSourceDialog,
                                icon: Icon(Icons.edit),
                                color: Constants.BUTTON_COLOR)),
                      ))
                ],
              )),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: key,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: userName,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'User Name'.tr(),
                    ),
                    onChanged: (val) => userName = val,
                    validator: (val) =>
                        val!.isEmpty ? 'Name can not be empty'.tr() : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: userSurname,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'User surname'.tr(),
                    ),
                    onChanged: (val) => userSurname = val,
                    validator: (val) =>
                        val!.isEmpty ? 'Surname can not be empty'.tr() : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    initialValue: userPhone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Phone number'.tr(),
                    ),
                    onChanged: (val) => userPhone = val,
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: saveButton(),
              )
            ],
          )
        ],
      ),
    );
  }
}
