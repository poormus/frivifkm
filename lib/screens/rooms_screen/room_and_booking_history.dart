import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/rooms_screen/rooms_screen.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:flutter/material.dart';

import 'booking_history.dart';



class RoomAndBookingHistory extends StatefulWidget {

  final CurrentUserData currentUserData;
  final String userRole;
  const RoomAndBookingHistory({Key? key, required this.currentUserData, required this.userRole}) : super(key: key);

  @override
  _RoomAndBookingHistoryState createState() => _RoomAndBookingHistoryState();
}

class _RoomAndBookingHistoryState extends State<RoomAndBookingHistory> {

  String currentTab='rooms';
  bool isFabVisible=true;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Rooms'.tr(), body: buildBody(), shouldScroll: false);
    return buildScaffold('Rooms'.tr(), context, buildBody(), null);
  }

  Widget buildBody(){
    return Column(
      mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Constants.TAB_HEIGHT,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          currentTab = 'rooms';
                        });
                      },
                      child: Text(
                        'Rooms'.tr(),
                        style: TextStyle(
                            color: currentTab == 'rooms'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey),
                      )),
                ),
                VerticalDivider(width: 3, color: Colors.grey),
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          currentTab = 'history';
                        });
                      },
                      child: Text('History'.tr(),
                          style: TextStyle(
                              color: currentTab == 'history'
                                  ? Constants.BUTTON_COLOR
                                  : Colors.grey))),
                ),
              ],
            ),
          ),
          Divider(
            height: 3,
            color: Colors.grey,
          ),
          if(currentTab=='rooms')...[
            RoomsScreen(currentUserData: widget.currentUserData, userRole: widget.userRole),
          ]else...[
            MyBookingHistory(userData: widget.currentUserData)
          ]
        ],
    );
  }
  Widget? buildFab(){
    return widget.userRole=='admin'?(isFabVisible?FloatingActionButton(
      backgroundColor: Constants.BUTTON_COLOR,
      onPressed: (){
        Navigation.navigateToAddEditRoomScreen(context, null, widget.currentUserData.currentOrganizationId, widget.userRole,widget.currentUserData);
      },
      child: Icon(Icons.add),
    ):null):null;
  }
}
