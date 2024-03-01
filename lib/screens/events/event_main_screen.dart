import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold_main_screen_item.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/screens/events/event_history.dart';
import 'package:firebase_calendar/screens/events/past_events.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'events.dart';

class EventMainScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final String subLevel;
  const EventMainScreen(
      {Key? key, required this.currentUserData, required this.userRole, required this.subLevel})
      : super(key: key);

  @override
  _EventMainScreenState createState() => _EventMainScreenState();
}

class _EventMainScreenState extends State<EventMainScreen> {
  String currentTab = 'events';
  final eventServices = EventServices();
  late Stream<List<Event>> allEventsOfOrganization;

  @override
  void initState() {
    allEventsOfOrganization=eventServices.getEventsForOrganization(widget.currentUserData.currentOrganizationId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BaseScaffoldMainScreenItem(body: buildBody());
    //return BaseScaffold(appBarName: 'Events'.tr(), body: buildBody(), shouldScroll: false);
    //return buildScaffold('Events', context, buildBody(), null);
  }

  Widget buildBody() {
    return StreamBuilder<List<Event>>(
      stream: allEventsOfOrganization,
      builder: (context, snapshot) {
        List<Event> events=[];
        if(snapshot.hasData){
          events=snapshot.data!;
        }else if(snapshot.hasError){
          Utils.showErrorToast();
        }
        return Column(
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
                            currentTab = 'events';
                          });
                        },
                        child: Text(
                          'Events'.tr(),
                          style: TextStyle(
                              color: currentTab == 'events'
                                  ? Constants.BUTTON_COLOR
                                  : Colors.grey),
                        )),
                  ),
                  VerticalDivider(width: 3, color: Colors.grey),
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            currentTab = 'pastEvents';
                          });
                        },
                        child: Text('Past events'.tr(),
                            style: TextStyle(
                                color: currentTab == 'pastEvents'
                                    ? Constants.BUTTON_COLOR
                                    : Colors.grey))),
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
            if (currentTab == 'events') ...[
              EventsScreen(
                  userRole: widget.userRole,
                  currentUserData: widget.currentUserData,
                  events: events,
                subLevel: widget.subLevel,
              )
            ] else if (currentTab == 'history') ...[
              EventHistory(
                  userRole: widget.userRole,
                  currentUserData: widget.currentUserData,
                  events: events,
                subLevel: widget.subLevel,
              )
            ] else ...[
              PastEvents(
                  userRole: widget.userRole,
                  currentUserData: widget.currentUserData,
                  events: events,
                subLevel: widget.subLevel,
              )
            ]
          ],
        );
      }
    );
  }
}
