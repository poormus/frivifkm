import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/models/event_data_source.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/no_data_or_progres_widget.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
//import 'package:add_2_calendar/add_2_calendar.dart' as localCalendar;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final List<Event> events;
  final String subLevel;
  EventsScreen(
      {Key? key,
      required this.currentUserData,
      required this.userRole,
      required this.events,
      required this.subLevel})
      : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // Storage storage=Storage();
  // late Future<String> accessToken;
  EventServices eventServices = EventServices();
  String query = '';

  //calendar related fields
  CalendarView _view = CalendarView.month;
  late EventDataSource dataSource;
  final CalendarController calendarController = CalendarController();
  final currentView = CalendarView.month;
  String currentViewType = 'list';

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // accessToken=storage.prefs.then((value){
    //   return value.getString('accessTokenData')??'';
    // });
    super.initState();
  }

  List<Event> _sortEvents(List<Event> events) {
    List<Event> sortedList = [];
    sortedList = events
        .where((element) =>
            element.eventName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: buildBody(context),
        floatingActionButton: buildFab(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<Event> myEvents = [];
    List<Event> declinedEvents = [];
    widget.events.forEach((event) {
      if (event.eventEndTime.isAfter(DateTime.now())) {
        bool isToMe = false;
        if (widget.currentUserData.groupIds
                    .toSet()
                    .intersection(event.toWho.toSet())
                    .length !=
                0 ||
            event.toWho.contains(widget.userRole)) {
          isToMe = true;
        }
        if (widget.userRole == '4' || widget.userRole == '3' || isToMe) {
          myEvents.add(event);
          if (isEventDeclined(event, widget.currentUserData.uid)) {
            declinedEvents.add(event);
          }
        }
      }
    });

    declinedEvents.forEach((declined) {
      myEvents.removeWhere((element) => element.eventId == declined.eventId);
    });
    declinedEvents.forEach((element) {
      myEvents.add(element);
    });
    if (myEvents.length == 0) {
      return NoDataWidget(
          info: 'No events yet'.tr(),
          isProgress: false,
          asset: 'assets/event_background.png');
    } else {
      final sortedList = _sortEvents(myEvents);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              currentViewType == 'calendar'
                  ? IconButton(
                      onPressed: () => _onCalendarIconTap(),
                      icon: Icon(Icons.calendar_month,
                          color: Constants.CANCEL_COLOR))
                  : Container(
                      width: size.width * 0.8,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: textInputDecoration.copyWith(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Constants.BACKGROUND_COLOR,
                                      width: 2.0)),
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
              currentViewType == 'calendar'
                  ? IconButton(
                      onPressed: () {
                        if (currentViewType == 'list') {
                          setState(() {
                            currentViewType = 'calendar';
                          });
                        } else {
                          setState(() {
                            currentViewType = 'list';
                          });
                        }
                      },
                      icon: Icon(Icons.calendar_today,
                          color: Constants.CANCEL_COLOR))
                  : Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: IconButton(
                          onPressed: () {
                            if (currentViewType == 'list') {
                              setState(() {
                                currentViewType = 'calendar';
                              });
                            } else {
                              setState(() {
                                currentViewType = 'list';
                              });
                            }
                          },
                          icon: Icon(Icons.calendar_today,
                              color: Constants.CANCEL_COLOR)),
                    )
            ],
          ),
          if (currentViewType == 'list') ...[
            Expanded(
              child: ListView.builder(
                  itemCount: sortedList.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    return buildListTile(sortedList[index], size, context);
                  }),
            ),
          ] else ...[
            buildCalendarView()
          ]
        ],
      );
    }
  }

  Widget buildListTile(Event event, Size size, BuildContext context) {
    return event.eventEndTime.isAfter(DateTime.now())
        ? GestureDetector(
            onTap: () {
              Navigation.navigateToEventDetail(
                  context,
                  widget.userRole,
                  event,
                  widget.currentUserData.currentOrganizationId,
                  widget.currentUserData,
                  widget.subLevel,
                  null);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
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
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                          )),
                      SizedBox(height: 10),
                      Text(event.eventName,
                          style: appTextStyle.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      Text(Utils.toDateTranslated(event.eventDate, context),
                          style: textStyle),
                      Text(
                        '${Utils.toTime(event.eventStartTime)} - ${Utils.toTime(event.eventEndTime)}',
                        style: textStyle,
                      ),
                      Text(event.eventAddress, style: textStyle),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: () {
                                    Navigation.navigateToEventChatScreen(
                                        context,
                                        widget.currentUserData,
                                        event.eventId,
                                        event.eventName);
                                  },
                                  child: Container(
                                      height: 40,
                                      child: Center(
                                          child: Text(
                                              'Comments (${event.commentCount})')))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomTextButton(
                                      width: size.width * 0.2,
                                      height: 35,
                                      text: event.declinedUids.contains(
                                              widget.currentUserData.uid)
                                          ? 'Declined'.tr()
                                          : 'Decline'.tr(),
                                      textColor: event.declinedUids.contains(
                                              widget.currentUserData.uid)
                                          ? Colors.white
                                          : Constants.CANCEL_COLOR,
                                      containerColor: event.declinedUids
                                              .contains(
                                                  widget.currentUserData.uid)
                                          ? Constants.CANCEL_COLOR
                                          : Constants.BACKGROUND_COLOR,
                                      press: () {
                                        eventServices
                                            .updateDeclinedUidList(event,
                                                widget.currentUserData.uid)
                                            .catchError((err) =>
                                                Utils.showToast(
                                                    context, err.toString()));
                                      }),
                                  SizedBox(width: 8),
                                  CustomTextButton(
                                      width: size.width * 0.2,
                                      height: 35,
                                      text: event.attendingUids.contains(
                                              widget.currentUserData.uid)
                                          ? 'Attending'.tr()
                                          : 'Attend'.tr(),
                                      textColor: event.attendingUids.contains(
                                              widget.currentUserData.uid)
                                          ? Colors.white
                                          : Constants.BUTTON_COLOR,
                                      containerColor: event.attendingUids
                                              .contains(
                                                  widget.currentUserData.uid)
                                          ? Constants.BUTTON_COLOR
                                          : Constants.BACKGROUND_COLOR,
                                      press: () {
                                        if (!event.attendingUids.contains(
                                            widget.currentUserData.uid)) {
                                          addToCalendar(event);
                                        }
                                        eventServices
                                            .updateAttendingUidList(event,
                                                widget.currentUserData.uid)
                                            .catchError((err) =>
                                                Utils.showToast(
                                                    context, err.toString()))
                                            .then((value) {
                                          //showAddToCalendarDialog(event);
                                        });
                                      }),
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  Widget? buildFab(BuildContext context) {
    return widget.userRole == '4' || widget.userRole == '3'
        ? FloatingActionButton(
            backgroundColor: Constants.BUTTON_COLOR,
            onPressed: () {
              Navigation.navigateToAddEditEventScreen(
                  context,
                  widget.currentUserData,
                  widget.userRole,
                  null,
                  widget.subLevel);
            },
            child: Icon(Icons.add),
          )
        : null;
  }

  Widget buildCalendarView() {
    dataSource = EventDataSource(widget.events);
    return Expanded(
      child: SfCalendar(
        onTap: _onCalendarTapped,
        onViewChanged: _onViewChanged,
        controller: calendarController,
        view: _view,
        dataSource: dataSource,
        initialSelectedDate: DateTime.now(),
      ),
    );
  }

  bool isEventDeclined(Event event, String uid) {
    return event.declinedUids.contains(uid);
  }

  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    if (_view == calendarController.view ||
        (_view != CalendarView.month &&
            calendarController.view != CalendarView.month)) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        _view = calendarController.view!;

        /// Update the current view when the calendar view changed to
        /// month view or from month view.
      });
    });
  }

  void _onCalendarIconTap() {
    if (calendarController.view == CalendarView.day) {
      calendarController.view = CalendarView.month;
    }
  }

  void _onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.header ||
        calendarTapDetails.targetElement == CalendarElement.resourceHeader) {
      return;
    }
    if (calendarController.view == CalendarView.month) {
      calendarController.view = CalendarView.day;
    }
  }

  // void showAddToCalendarDialog(Event myEvent) {
  //   showDialog(context: context, builder: (context){
  //     return BlurryDialogNew(title: 'Do you want to add this event to your calendar?'.tr(),
  //         continueCallBack: (){
  //
  //           googleapis.Event event=googleapis.Event();
  //           googleapis.EventDateTime start = new googleapis.EventDateTime();
  //           googleapis.EventDateTime end = new googleapis.EventDateTime();
  //
  //           start.date=myEvent.eventStartTime;
  //           start.timeZone=myEvent.eventStartTime.timeZoneName;
  //           event.start=start;
  //
  //           end.date=myEvent.eventEndTime;
  //           end.timeZone=myEvent.eventEndTime.timeZoneName;
  //           event.end=end;
  //
  //           event.description=myEvent.eventName;
  //           event.summary=myEvent.eventInformation;
  //
  //           var _credentials;
  //           if (Platform.isAndroid) {
  //             _credentials = new auth.ClientId(
  //                 Configuration.ANDROID_CLIENT_ID,
  //                 "");
  //
  //             accessToken.then((value) {
  //               if(value==''){
  //                 auth.clientViaUserConsent(_credentials, Configuration.scopes, prompt).then((auth.AuthClient client){
  //                   saveData(client.credentials);
  //                 });
  //               }
  //             });
  //             insertEvent(event, _credentials);
  //           } else if (Platform.isIOS) {
  //             _credentials = new auth.ClientId(
  //                 Configuration.IOS_CLIENT_ID,
  //                 "");
  //             accessToken.then((value) {
  //               if(value==''){
  //                 auth.clientViaUserConsent(_credentials, Configuration.scopes, prompt).then((auth.AuthClient client){
  //                   saveData(client.credentials);
  //                 });
  //               }
  //             });
  //             insertEvent(event, _credentials);
  //           }
  //         });
  //   });
  // }
  //
  // insertEvent(event,auth.ClientId _clientID) async {
  //
  //   try {
  //     print('insert event');
  //     var client = http.Client();
  //      await storage.getCreds().then((value) async {
  //      var accessCredentials = await auth.refreshCredentials(_clientID, value, client);
  //      final authClient=auth.autoRefreshingClient(_clientID,accessCredentials, client);
  //      var calendar = googleapis.CalendarApi(authClient);
  //      String calendarId = "primary";
  //      // calendar.events.list(calendarId).then((value) {
  //      //   value.items?.forEach((element) {
  //      //     print(element.description);
  //      //   });
  //      //
  //      // });
  //      calendar.events.insert(event,calendarId).then((value) {
  //        Navigator.pop(context);
  //        print("ADDEDDD_________________${value.status}");
  //        if (value.status == "confirmed") {
  //          log('Event added in google calendar');
  //        } else {
  //          log("Unable to add event in google calendar");
  //        }
  //      }).catchError((e) {
  //        print(e);
  //      });
  //    });
  //   } catch (e) {
  //     log('Auth error $e');
  //   }
  // }
  //
  // void saveData(auth.AccessCredentials credentials) {
  //
  //   storage.saveString("accessTokenData",credentials.accessToken.data);
  //   storage.saveString("accessTokenExpiry",credentials.accessToken.expiry.toString(),);
  //   storage.saveString("refreshToken",credentials.refreshToken??'');
  //   storage.saveListString("scopes", credentials.scopes);
  //   storage.saveString("idToken",credentials.idToken??'');
  //
  //   // storage.write( 'credentials',{
  //   //   "accessTokenData": credentials.accessToken.data,
  //   //   "accessTokenExpiry": credentials.accessToken.expiry.toString(),
  //   //   "refreshToken": credentials.refreshToken,
  //   //   "scopes": credentials.scopes,
  //   //   "idToken": credentials.idToken
  //   // });
  //   // storage.saveAccessToken(credentials.accessToken.data);
  // }

  void prompt(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void addToCalendar(Event event) async {
    /* var status = await Permission.calendar.status;
    if (status.isGranted) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool isCalendarAddEnabled =
          preferences.getBool('enableCalendar') ?? false;
      if (isCalendarAddEnabled) {
        BlurryDialogNew dialog = BlurryDialogNew(
            title: 'Add to your calendar?'.tr(),
            continueCallBack: () {
              final localEvent = localCalendar.Event(
                title: event.eventName,
                description: event.eventInformation,
                location: event.eventAddress,
                startDate: event.eventStartTime,
                endDate: event.eventEndTime,
                iosParams: localCalendar.IOSParams(
                  reminder: Duration(
                      /* Ex. hours:1 */), // on iOS, you can set alarm notification after your event.
                ),
                androidParams: localCalendar.AndroidParams(
                  emailInvites: [], // on Android, you can add invite emails to your event.
                ),
              );
              localCalendar.Add2Calendar.addEvent2Cal(localEvent);
              Navigator.pop(context);
              print('added');
            });
        showDialog(
            context: context,
            builder: (context) {
              return dialog;
            });
      }
    } else if (!status.isGranted) {
      await Permission.calendar.request();
    } */
  }
}
