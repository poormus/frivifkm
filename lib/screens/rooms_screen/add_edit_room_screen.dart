import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/dialog/select_image_dialog.dart';
import 'package:firebase_calendar/models/room.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../models/current_user_data.dart';
import '../../shared/constants.dart';

class AddEditRoom extends StatefulWidget {
  final Room? room;
  final String companyId;
  final String userRole;
  final CurrentUserData currentUserData;
  const AddEditRoom(
      {Key? key,
      this.room,
      required this.companyId,
      required this.userRole,
      required this.currentUserData})
      : super(key: key);

  @override
  _AddEditRoomState createState() => _AddEditRoomState();
}

class _AddEditRoomState extends State<AddEditRoom> {
  File? imageFile;

  late String roomSize;

  late String roomCapacity;

  late String roomName;

  final firebaseService = FireBaseServices();

  late List<String> amenitiesList;

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

  Future saveOrUpdateRoom() async {
    if (widget.room == null) {
      if (Utils.validateAddRoom(
          imageFile, roomName, roomCapacity, roomSize, context)) {
        await firebaseService
            .addRoom(widget.companyId, roomCapacity, roomName, roomSize,
                imageFile!, amenitiesList, context, widget.currentUserData.uid)
            .catchError((err) => Utils.showToast(context, err.toString()));
      }
    } else {
      if (Utils.validateAddRoomForUpdate(
          roomName, roomCapacity, roomSize, context)) {
        await firebaseService
            .updateRoom(
                widget.companyId,
                widget.room!.roomId,
                roomCapacity,
                roomName,
                roomSize,
                imageFile,
                widget.room!.roomUrl,
                amenitiesList,
                context,
                widget.currentUserData.uid)
            .catchError((err) => Utils.showToast(context, err.toString()));
      }
    }
  }

  @override
  void initState() {
    roomSize = widget.room == null ? '' : widget.room!.roomSize;
    roomCapacity = widget.room == null ? '' : widget.room!.roomCapacity;
    roomName = widget.room == null ? '' : widget.room!.roomName;
    amenitiesList = widget.room == null ? [] : widget.room!.amenities;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Add/Edit room'.tr(),
        body: buildBody(size),
        shouldScroll: true);
  }

  Widget buildBody(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                width: size.width * 0.85,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: widget.room == null
                          ? (imageFile != null
                              ? FileImage(imageFile!)
                              : AssetImage('assets/background_holder.png')
                                  as ImageProvider)
                          : (imageFile != null)
                              ? FileImage(imageFile!)
                              : NetworkImage(widget.room!.roomUrl)
                                  as ImageProvider),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Constants.BUTTON_COLOR,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: showSelectImageSourceDialog,
                        icon: Icon(
                          Icons.edit,
                          color: Constants.BACKGROUND_COLOR,
                        ),
                      ))),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        width: size.width * 0.4,
                        child: TextFieldInput(
                          maxLength: 20,
                          hintText: 'Room name'.tr(),
                          onChangeValue: (s) => roomName = s,
                          isDone: true,
                          shouldObscureText: false,
                          initialValue: roomName,
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Name'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        width: size.width * 0.4,
                        child: TextFieldInput(
                          textInputType: TextInputType.number,
                          maxLength: 3,
                          hintText: 'Capacity'.tr(),
                          onChangeValue: (s) => roomCapacity = s,
                          isDone: true,
                          shouldObscureText: false,
                          initialValue: roomCapacity,
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Capacity'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                  width: size.width * 0.85,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Constants.CONTAINER_COLOR,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildRowItem('White board'.tr(), size, '1'),
                          buildRowItem('Projector'.tr(), size, '2'),
                          buildRowItem('Wifi'.tr(), size, '3'),
                          buildRowItem('TV'.tr(), size, '4'),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          buildRowItem('Air conditioner'.tr(), size, '5'),
                          buildRowItem('Toilet'.tr(), size, '6'),
                          buildRowItem('Coffee'.tr(), size, '7'),
                        ],
                      ),
                    ],
                  )),
              Positioned.fill(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Amenities'.tr(),
                      style: textStyle,
                    )),
              ))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Stack(
            children: [
              Container(
                width: size.width * 0.85,
                height: 100,
                decoration: BoxDecoration(
                  color: Constants.CONTAINER_COLOR,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: size.width * 0.5,
                  child: TextFieldInput(
                      maxLength: 100,
                      initialValue: roomSize,
                      hintText: 'Information'.tr(),
                      onChangeValue: (s) => roomSize = s,
                      isDone: true,
                      shouldObscureText: false),
                ),
              ),
              Positioned.fill(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'Information'.tr(),
                      style: textStyle,
                    )),
              ))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PrimaryButton(
                    text: widget.room == null
                        ? 'Save Room'.tr()
                        : 'Update Room'.tr(),
                    press: saveOrUpdateRoom,
                    color: Constants.BUTTON_COLOR),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildRowItem(String name, Size size, String index) {
    bool isInTheList = amenitiesList.contains(index);
    return GestureDetector(
      onTap: () {
        if (amenitiesList.contains(index)) {
          setState(() {
            amenitiesList.remove(index);
          });
        } else {
          setState(() {
            amenitiesList.add(index);
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            Text(name),
            SizedBox(
              width: size.width * 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isInTheList ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
