import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';


class EventHistory extends StatelessWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final List<Event> events;
  final EventServices eventServices = EventServices();
  final String subLevel;
   EventHistory({Key? key, required this.currentUserData, required this.userRole, required this.events, required this.subLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final attendedEvents=[];

    events.forEach((element) {
      bool isEventOver=element.eventDate.isBefore(DateTime.now());
      bool didIJoin=element.attendingUids.contains(currentUserData.uid);
      if(isEventOver&& didIJoin){
        attendedEvents.add(element);
      }
    });

    if (attendedEvents.length == 0) {
      return noDataWidget('Your past attended events appear here'.tr(), false);
    } else {
      return Expanded(
        child: ListView.builder(
            itemCount: attendedEvents.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return buildListTile(attendedEvents[index], size, context);
            }),
      );
    }
  }

  Widget buildListTile(Event event,Size size,BuildContext context){
    return GestureDetector(
      onTap: (){Navigation.navigateToEventDetail(context,userRole,event,currentUserData.currentOrganizationId,currentUserData,subLevel,null);},
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0,left: 5,right: 5),
            child: Column(
              children: [
                Text(Utils.getMonthName(event.eventDate.month-1,context),style: textStyle,),
                Text(event.eventDate.day.toString(),style: appTextStyle.copyWith(fontSize: 20,fontWeight: FontWeight.bold)),
                Text(Utils.getWeekName(event.eventDate.weekday-1,context),style: textStyle,),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            width: size.width-40,
            child: Card(
                color: Constants.CONTAINER_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              child: Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: size.width-40,
                        height: 150,
                        imageUrl: event.eventUrl,
                        placeholder: (context, url) =>
                            Align(child: new CircularProgressIndicator()),
                        errorWidget: (context, url, error) => new Icon(Icons.error),
                      )),
                  Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Constants.BACKGROUND_COLOR,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(event.eventName,style: appTextStyle.copyWith(color: Colors.black,fontSize: 22),))),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
