import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/admin_panel/approve_booking.dart';
import 'package:firebase_calendar/screens/admin_panel/approve_new_user.dart';
import 'package:firebase_calendar/screens/admin_panel/manage_members.dart';
import 'package:firebase_calendar/screens/admin_panel/manage_organization.dart';
import 'package:firebase_calendar/screens/admin_panel/work_time_screen.dart';
import 'package:firebase_calendar/services/group_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/my_appointment.dart';
import '../../services/admin_services.dart';
import '../../services/work_time_services.dart';

class AdminPanel extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String subLevel;
  final String? notificationPage;
  const AdminPanel({Key? key, required this.currentUserData,
    required this.subLevel, this.notificationPage}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String clickedTab = 'users';
  AdminServices adminServices = AdminServices();
  late WorkTimeServices workTimeService;
  late Stream<List<MyAppointment>> getBookings;
  @override
  void initState() {
    workTimeService=WorkTimeServices(organizationId: widget.currentUserData.currentOrganizationId);
    workTimeService.init();
    getBookings=adminServices.getBookingsToApprove(widget.currentUserData.currentOrganizationId);
    if(widget.notificationPage!=null){
      clickedTab=widget.notificationPage!;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<MyProvider>(context);
    return BaseScaffold(appBarName: 'Admin panel'.tr(), body: buildBody(provider), shouldScroll: false);
  }

  Widget buildBody(MyProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: Constants.TAB_HEIGHT,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      clickedTab = 'users';
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                          Icons.people_alt,
                          size: 30,color: clickedTab == 'users'
                          ? Constants.BUTTON_COLOR
                          : Colors.grey
                      ),
                      Text(
                        'Users'.tr(),
                        style: TextStyle(
                            fontSize: 10,
                            color: clickedTab == 'users'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.subLevel==''||widget.subLevel=='freemium'? null:setState(() {
                      clickedTab = 'new bookings';
                    });
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 30,color: clickedTab == 'new bookings'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey
                            ),
                            Text(
                              'New bookings'.tr(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: clickedTab == 'new bookings'
                                      ? Constants.BUTTON_COLOR
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder<List<MyAppointment>>(
                        stream: getBookings,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            final totalBookings=snapshot.data!.length;
                            if(totalBookings==0){
                              return Container();
                            }else{
                              return Positioned(
                                left: 5,
                                top: 5,
                                child: new Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: new BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: new Text(
                                    totalBookings.toString(),
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          }else{
                            return Container();
                          }
                        }
                      ),
                      widget.subLevel==''||widget.subLevel=='freemium'?Icon(Icons.lock,color: Constants.CANCEL_COLOR):Container()
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.subLevel==''||widget.subLevel=='freemium'? null:setState(() {
                      clickedTab = 'work time';
                    });
                  },
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(
                                Icons.work_outlined,
                                size: 30,color: clickedTab == 'work time'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey
                            ),
                            Text(
                              'Work time'.tr(),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: clickedTab == 'work time'
                                      ? Constants.BUTTON_COLOR
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      widget.subLevel==''||widget.subLevel=='freemium'?Icon(Icons.lock,color: Constants.CANCEL_COLOR):Container()
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      clickedTab = 'organization';
                    });
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 30,color: clickedTab == 'organization'
                          ? Constants.BUTTON_COLOR
                          : Colors.grey
                      ),
                      Text(
                        'Organization'.tr(),
                        style: TextStyle(
                            fontSize: 10,
                            color: clickedTab == 'organization'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 3,
          color: Colors.grey,
        ),
        SizedBox(height: 5),
        if (clickedTab == 'users') ...[
          ManageMembers(currentUserData: widget.currentUserData)
        ] else if (clickedTab == 'new bookings') ...[
          ApproveBooking(currentUserData: widget.currentUserData,adminServices: adminServices,)
        ] else if (clickedTab == 'work time') ...[
           FutureBuilder(
               future: Future.delayed(Duration(seconds: 4)),
               builder: (c,s){
                 workTimeService.getWorkTimeForAdmin(widget.currentUserData.currentOrganizationId,provider);
                 if(s.connectionState==ConnectionState.done){
                   return WorkTimeScreen(currentUserData: widget.currentUserData);
                 }else return Column(
                   children: [
                     CircularProgressIndicator(),
                     SizedBox(height: 5,),
                     Center(child: Text('Fetching data'.tr())),
                   ],
                 );
               })
        ]else if(clickedTab=='organization')...[
          ManageOrganization(currentUserData: widget.currentUserData)
        ]
      ],
    );
  }
}
