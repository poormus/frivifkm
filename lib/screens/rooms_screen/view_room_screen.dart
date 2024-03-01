import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/room.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/constants.dart';

class ViewRoomScreen extends StatefulWidget {
  final Room room;
  final String companyId;
  final String userRole;
  final CurrentUserData currentUserData;
  const ViewRoomScreen(
      {Key? key,
      required this.room,
      required this.companyId,
      required this.userRole, required this.currentUserData})
      : super(key: key);

  @override
  _ViewRoomScreenState createState() => _ViewRoomScreenState();
}

class _ViewRoomScreenState extends State<ViewRoomScreen> {


  late String roomSize = "";
  late String roomCapacity = "";
  late String roomName = "";
  final firebaseService = FireBaseServices();
  late List<String> amenitiesList;

  @override
  void initState() {
    roomSize = widget.room.roomSize;
    roomCapacity = widget.room.roomCapacity;
    roomName = widget.room.roomName;
    amenitiesList = widget.room.amenities;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return buildScaffold('Room details'.tr(), context, buildBody(size), null);
  }

  showDeleteRoomConfirmationDialog() {
    BlurryDialogNew dialog = BlurryDialogNew(
        title: 'Delete this room?'.tr(),
        continueCallBack: deleteRoom);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  deleteRoom() async {
    Navigator.of(context).pop();
    await firebaseService
        .deleteRoom(widget.room.roomId,context)
        .catchError((err) => Utils.showToast(context, err.toString()));

  }

  navigateToEditPage() {
    Navigator.pop(context);
    Navigation.navigateToAddEditRoomScreen(
        context, widget.room, widget.companyId, '',widget.currentUserData);
  }

  Widget buildBody(Size size) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                width: size.width * 0.85,
                height: 150,
                imageUrl: widget.room.roomUrl,
                placeholder: (context, url) =>
                    Align(child: new CircularProgressIndicator()),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              )),
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
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                roomName,
                                style: appTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 18),
                              ),
                            ))),
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
                    Positioned.fill(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            roomCapacity,
                            style: appTextStyle.copyWith(fontWeight: FontWeight.bold,fontSize: 20),
                          )),
                    ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              buildRowItem('White board'.tr(), size,'1'),
                              buildRowItem('Projector'.tr(), size,'2'),
                              buildRowItem('Wifi'.tr(), size,'3'),
                              buildRowItem('TV'.tr(), size,'4'),
                            ],
                          ),
                          SizedBox(width: 5,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              buildRowItem('Air conditioner'.tr(), size,'5'),
                              buildRowItem('Toilet'.tr(), size,'6'),
                              buildRowItem('Coffee'.tr(), size,'7'),
                            ],
                          ),
                        ],
                      ),
                    ),
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
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                width: size.width * 0.85,
                height: 100,
                decoration: BoxDecoration(
                  color: Constants.CONTAINER_COLOR,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    roomSize,
                    style: appTextStyle,
                  ),
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
          SizedBox(height: 10),
          if (widget.userRole == '4'|| widget.room.createdBy == widget.currentUserData.uid) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PrimaryButton(
                      text: 'Delete Room'.tr(),
                      press: showDeleteRoomConfirmationDialog,
                      color: Constants.CANCEL_COLOR),
                  PrimaryButton(
                      text: 'Edit Room'.tr(),
                      press: navigateToEditPage,
                      color: Constants.BUTTON_COLOR),
                ],
              ),
            ),
          ],
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildRowItem(String name, Size size,String index) {
    bool isInTheList = amenitiesList.contains(index);
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
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
                      isInTheList ? Icons.check_circle:null,size: 20,
                    ),
                  ],
                ),
              ],
            )

    );
  }
}
