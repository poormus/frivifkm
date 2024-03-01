import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/no_data_or_progres_widget.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class PastEvents extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final List<Event> events;
  final String subLevel;
  PastEvents({Key? key, required this.currentUserData, required this.userRole, required this.events, required this.subLevel}) : super(key: key);

  @override
  State<PastEvents> createState() => _PastEventsState();
}

class _PastEventsState extends State<PastEvents> {
  EventServices eventServices = EventServices();

  String query = '';

  List<Event> _sortEvents(List<Event> events){
    List<Event> sortedList=[];
    sortedList = events
        .where((element) => element.eventName
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: buildBody(context),
      ),
    );
  }


  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Event> myEvents=[];
    widget.events.forEach((event) {
      bool isToMe=false;
      if(widget.currentUserData.groupIds.toSet().intersection(event.toWho.toSet()).length!=0
          || event.toWho.contains(widget.userRole)
      ){
        isToMe=true;
      }

      if(widget.userRole=='4' ||widget.userRole=='3' || isToMe){
        myEvents.add(event);
      }
    });
    if (myEvents.length == 0) {
      return NoDataWidget(info: 'No events yet'.tr()
        , isProgress: false,asset: 'assets/event_background.png',);
    } else {
      final sortedList=_sortEvents(myEvents);
      return Column(
        children: [
          Center(
            child: Container(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: textInputDecoration.copyWith(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Constants.BACKGROUND_COLOR, width: 2.0)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Constants.BACKGROUND_COLOR,
                      ),
                      hintText: Strings.SEARCH.tr()),
                  onFieldSubmitted: (val) {
                    setState(() {
                      query = val;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: sortedList.length,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return buildListTile(sortedList[index], size, context);
                }),
          ),
        ],
      );
    }
  }

  Widget buildListTile(Event event, Size size, BuildContext context) {
    return event.eventEndTime.isBefore(DateTime.now())   ? GestureDetector(
      onTap: (){Navigation.navigateToEventDetail(context,widget.userRole,event,
          widget.currentUserData.currentOrganizationId,widget.currentUserData,widget.subLevel,null);},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
        child: Card(
          color: Constants.CARD_COLOR,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: size.width,
                      height: 200,
                      imageUrl: event.eventUrl,
                      placeholder: (context, url) =>
                          Align(child: new CircularProgressIndicator()),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                    )),
                SizedBox(height: 10),
                Text(event.eventName,
                    style: appTextStyle.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 22)),
                Text(Utils.toDateTranslated(event.eventDate,context), style: textStyle),
                Text(
                  '${Utils.toTime(event.eventStartTime)} - ${Utils.toTime(event.eventEndTime)}',
                  style: textStyle,
                ),
                Text(event.eventAddress, style: textStyle),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    ):Container() ;
  }
}
